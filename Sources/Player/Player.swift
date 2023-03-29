//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import DequeModule
import MediaPlayer
import TimelaneCombine

/// An audio / video player maintaining its items as a double-ended queue (deque).
public final class Player: ObservableObject, Equatable {
    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle

    /// Current media type.
    @Published public private(set) var mediaType: MediaType = .unknown

    /// Returns whether the player is currently buffering.
    @Published public private(set) var isBuffering = false

    /// Returns whether the player is currently seeking to another position.
    @Published public private(set) var isSeeking = false

    /// The index of the current item in the queue.
    @Published public private(set) var currentIndex: Int?

    /// Duration of a chunk for the currently played item.
    @Published public private(set) var chunkDuration: CMTime = .invalid

    /// Indicates whether the player is currently playing video in external playback mode.
    @Published public private(set) var isExternalPlaybackActive = false

    /// Set whether trackers are enabled or not.
    @Published public var isTrackingEnabled = true

    @Published private var currentTracker: CurrentTracker?
    @Published private var currentItem: CurrentItem = .good(nil)
    @Published private var storedItems: Deque<PlayerItem>

    /// The type of stream currently played.
    public var streamType: StreamType {
        StreamType(for: timeRange, itemDuration: itemDuration)
    }

    /// The current time.
    public var time: CMTime {
        queuePlayer.currentTime().clamped(to: timeRange)
    }

    /// The available time range or `.invalid` when not known.
    public var timeRange: CMTimeRange {
        queuePlayer.timeRange
    }

    /// Returns whether the player is currently busy (buffering or seeking).
    public var isBusy: Bool {
        isBuffering || isSeeking
    }

    /// The low-level system player. Exposed for specific read-only needs like interfacing with `AVPlayer`-based
    /// 3rd party APIs. Mutating the state of this player directly is not supported and leads to undefined behavior.
    public var systemPlayer: AVPlayer {
        queuePlayer
    }

    /// The current item duration or `.invalid` when not known.
    private var itemDuration: CMTime {
        queuePlayer.itemDuration
    }

    let queuePlayer = QueuePlayer()
    private let nowPlayingSession: MPNowPlayingSession

    public let configuration: PlayerConfiguration
    private var cancellables = Set<AnyCancellable>()

    private var commandRegistrations: [any RemoteCommandRegistrable] = []

    var backwardSkipTime: CMTime {
        CMTime(seconds: -configuration.backwardSkipInterval, preferredTimescale: 1)
    }
    var forwardSkipTime: CMTime {
        CMTime(seconds: configuration.forwardSkipInterval, preferredTimescale: 1)
    }

    /// Create a player with a given item queue.
    /// - Parameters:
    ///   - items: The items to be queued initially.
    ///   - configuration: The configuration to apply to the player.
    public init(items: [PlayerItem] = [], configuration: PlayerConfiguration = .init()) {
        storedItems = Deque(items)

        nowPlayingSession = MPNowPlayingSession(players: [queuePlayer])
        nowPlayingSession.becomeActiveIfPossible()

        self.configuration = configuration

        configurePlaybackStatePublisher()
        configureChunkDurationPublisher()
        configureSeekingPublisher()
        configureBufferingPublisher()
        configureCurrentItemPublisher()
        configureCurrentIndexPublisher()
        configureCurrentTrackerPublisher()
        configureControlCenterPublishers()
        configureQueueUpdatePublisher()
        configureExternalPlaybackPublisher()
        configureMediaTypePublisher()

        configurePlayer()
    }

    /// Create a player with a single item in its queue.
    /// - Parameters:
    ///   - item: The item to queue.
    ///   - configuration: The configuration to apply to the player.
    public convenience init(item: PlayerItem, configuration: PlayerConfiguration = .init()) {
        self.init(items: [item], configuration: configuration)
    }

    public nonisolated static func == (lhs: Player, rhs: Player) -> Bool {
        lhs === rhs
    }

    private func configurePlayer() {
        queuePlayer.allowsExternalPlayback = configuration.allowsExternalPlayback
        queuePlayer.usesExternalPlaybackWhileExternalScreenIsActive = configuration.usesExternalPlaybackWhileMirroring
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = configuration.preventsDisplaySleepDuringVideoPlayback
        queuePlayer.audiovisualBackgroundPlaybackPolicy = configuration.audiovisualBackgroundPlaybackPolicy
    }

    deinit {
        queuePlayer.cancelPendingReplacements()
        uninstallRemoteCommands()
    }
}

public extension Player {
    /// Resume playback.
    func play() {
        queuePlayer.play()
    }

    /// Pause playback.
    func pause() {
        queuePlayer.pause()
    }

    /// Toggle playback between play and pause.
    func togglePlayPause() {
        if queuePlayer.rate != 0 {
            queuePlayer.pause()
        }
        else {
            queuePlayer.play()
        }
    }
}

public extension Player {
    /// Check whether seeking to a specific time is possible.
    /// - Parameter time: The time to seek to.
    /// - Returns: `true` if possible.
    func canSeek(to time: CMTime) -> Bool {
        guard timeRange.isValidAndNotEmpty else { return false }
        return timeRange.start <= time && time <= timeRange.end
    }

    /// Seek to a given position.
    /// - Parameters:
    ///   - position: The position to seek to.
    ///   - smooth: Set to `true` to enable smooth seeking. This allows any currently pending seek to complete before
    ///     any new seek is performed, preventing unnecessary cancellation. This makes it possible for the playhead
    ///     position to be moved in a smoother way.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs
    ///     whether the seek could finish without being cancelled.
    func seek(
        _ position: Position,
        smooth: Bool = true,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        // Mitigates issues arising when seeking to the very end of the range by introducing a small offset.
        let time = position.time.clamped(to: timeRange, offset: CMTime(value: 1, timescale: 10))
        guard time.isValid else {
            completion(true)
            return
        }
        queuePlayer.seek(
            to: time,
            toleranceBefore: position.toleranceBefore,
            toleranceAfter: position.toleranceAfter,
            smooth: smooth,
            completionHandler: completion
        )
    }
}

public extension Player {
    /// Return whether the current player item player can be returned to its default position.
    /// - Returns: `true` if skipping to the default position is possible.
    func canSkipToDefault() -> Bool {
        switch streamType {
        case .onDemand, .live:
            return true
        case .dvr where chunkDuration.isValid:
            return time < timeRange.end - chunkDuration
        default:
            return false
        }
    }

    /// Return the current item to its default position.
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipToDefault(completion: @escaping (Bool) -> Void = { _ in }) {
        switch streamType {
        case .dvr:
            seek(after(timeRange.end)) { finished in
                completion(finished)
            }
        default:
            seek(near(.zero)) { finished in
                completion(finished)
            }
        }
    }
}

public extension Player {
    /// Check whether skipping backward is possible.
    /// - Returns: `true` if possible.
    func canSkipBackward() -> Bool {
        timeRange.isValidAndNotEmpty
    }

    /// Check whether skipping forward is possible.
    /// - Returns: `true` if possible.
    func canSkipForward() -> Bool {
        guard timeRange.isValidAndNotEmpty else { return false }
        if itemDuration.isIndefinite {
            let currentTime = queuePlayer.targetSeekTime ?? time
            return canSeek(to: currentTime + forwardSkipTime)
        }
        else {
            return true
        }
    }

    /// Skip backward.
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipBackward(completion: @escaping (Bool) -> Void = { _ in }) {
        skip(withInterval: backwardSkipTime, toleranceBefore: .positiveInfinity, toleranceAfter: .zero, completion: completion)
    }

    /// Skip forward.
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipForward(completion: @escaping (Bool) -> Void = { _ in }) {
        skip(withInterval: forwardSkipTime, toleranceBefore: .zero, toleranceAfter: .positiveInfinity, completion: completion)
    }

    private func skip(
        withInterval interval: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        assert(interval != .zero)
        let endTolerance = CMTime(value: 1, timescale: 1)
        let currentTime = queuePlayer.targetSeekTime ?? time
        if interval < .zero || currentTime < timeRange.end - endTolerance {
            seek(
                to(currentTime + interval, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter),
                smooth: true,
                completion: completion
            )
        }
        else {
            completion(true)
        }
    }
}

public extension Player {
    /// Return a publisher periodically emitting the current time while the player is playing content. Does not emit any
    /// value on subscription and only emits valid times.
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: queuePlayer, interval: interval, queue: queue)
    }

    /// Return a publisher emitting when traversing the specified times during normal playback.
    /// - Parameters:
    ///   - times: The times to observe.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    func boundaryTimePublisher(for times: [CMTime], queue: DispatchQueue = .main) -> AnyPublisher<Void, Never> {
        Publishers.BoundaryTimePublisher(for: queuePlayer, times: times, queue: queue)
    }
}

public extension Player {
    /// The items queued by the player.
    var items: [PlayerItem] {
        get {
            Array(storedItems)
        }
        set {
            let range = storedItems.startIndex..<storedItems.endIndex
            storedItems.replaceSubrange(range, with: newValue)
        }
    }

    /// Items before the current item (not included).
    /// - Returns: Items.
    var previousItems: [PlayerItem] {
        guard let currentIndex else { return [] }
        return Array(storedItems.prefix(upTo: currentIndex))
    }

    /// Return the list of items to be loaded to return to the previous (playable) item.
    private var returningItems: [PlayerItem] {
        Self.items(before: currentIndex, in: storedItems)
    }

    /// Items past the current item (not included).
    /// - Returns: Items.
    var nextItems: [PlayerItem] {
        guard let currentIndex else {
            return Array(storedItems)
        }
        return Array(storedItems.suffix(from: currentIndex).dropFirst())
    }

    /// Return the list of items to be loaded to advance to the next (playable) item.
    private var advancingItems: [PlayerItem] {
        Self.items(after: currentIndex, in: storedItems)
    }

    private func canInsert(_ item: PlayerItem, before beforeItem: PlayerItem?) -> Bool {
        guard let beforeItem else { return true }
        return storedItems.contains(beforeItem) && !storedItems.contains(item)
    }

    /// Insert an item before another item. Does nothing if the item already belongs to the deque.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the deque.
    /// - Returns: `true` iff the item could be inserted.
    @discardableResult
    func insert(_ item: PlayerItem, before beforeItem: PlayerItem?) -> Bool {
        guard canInsert(item, before: beforeItem) else { return false }
        if let beforeItem {
            guard let index = storedItems.firstIndex(of: beforeItem) else { return false }
            storedItems.insert(item, at: index)
        }
        else {
            storedItems.prepend(item)
        }
        return true
    }

    private func canInsert(_ item: PlayerItem, after afterItem: PlayerItem?) -> Bool {
        guard let afterItem else { return true }
        return storedItems.contains(afterItem) && !storedItems.contains(item)
    }

    /// Insert an item after another item. Does nothing if the item already belongs to the deque.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the back of
    ///     the deque. If this item does not exist the method does nothing.
    /// - Returns: `true` iff the item could be inserted.
    @discardableResult
    func insert(_ item: PlayerItem, after afterItem: PlayerItem?) -> Bool {
        guard canInsert(item, after: afterItem) else { return false }
        if let afterItem {
            guard let index = storedItems.firstIndex(of: afterItem) else { return false }
            storedItems.insert(item, at: storedItems.index(after: index))
        }
        else {
            storedItems.append(item)
        }
        return true
    }

    /// Prepend an item to the deque.
    /// - Parameter item: The item to prepend.
    /// - Returns: `true` iff the item could be prepended.
    @discardableResult
    func prepend(_ item: PlayerItem) -> Bool {
        insert(item, before: nil)
    }

    /// Append an item to the deque.
    /// - Parameter item: The item to append.
    /// - Returns: `true` iff the item could be appended.
    @discardableResult
    func append(_ item: PlayerItem) -> Bool {
        insert(item, after: nil)
    }

    private func canMove(_ item: PlayerItem, before beforeItem: PlayerItem?) -> Bool {
        guard storedItems.contains(item) else { return false }
        if let beforeItem {
            guard item !== beforeItem, let index = storedItems.firstIndex(of: beforeItem) else { return false }
            guard index > 0 else { return true }
            return storedItems[storedItems.index(before: index)] !== item
        }
        else {
            return storedItems.first !== item
        }
    }

    /// Move an item before another item.
    /// - Parameters:
    ///   - item: The item to move. The method does nothing if the item does not belong to the deque.
    ///   - beforeItem: The item before which the moved item must be relocated. Pass `nil` to move the item to the
    ///     front of the deque. If the item does not belong to the deque the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: PlayerItem, before beforeItem: PlayerItem?) -> Bool {
        guard canMove(item, before: beforeItem), let movedIndex = storedItems.firstIndex(of: item) else {
            return false
        }
        if let beforeItem {
            guard let index = storedItems.firstIndex(of: beforeItem) else { return false }
            storedItems.move(from: movedIndex, to: index)
        }
        else {
            storedItems.move(from: movedIndex, to: storedItems.startIndex)
        }
        return true
    }

    private func canMove(_ item: PlayerItem, after afterItem: PlayerItem?) -> Bool {
        guard storedItems.contains(item) else { return false }
        if let afterItem {
            guard item !== afterItem, let index = storedItems.firstIndex(of: afterItem) else { return false }
            guard index < storedItems.count - 1 else { return true }
            return storedItems[storedItems.index(after: index)] !== item
        }
        else {
            return storedItems.last !== item
        }
    }

    /// Move an item after another item.
    /// - Parameters:
    ///   - item: The item to move.
    ///   - afterItem: The item after which the moved item must be relocated. Pass `nil` to move the item to the
    ///     back of the deque. If the item does not belong to the deque the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: PlayerItem, after afterItem: PlayerItem?) -> Bool {
        guard canMove(item, after: afterItem), let movedIndex = storedItems.firstIndex(of: item) else {
            return false
        }
        if let afterItem {
            guard let index = storedItems.firstIndex(of: afterItem) else { return false }
            storedItems.move(from: movedIndex, to: storedItems.index(after: index))
        }
        else {
            storedItems.move(from: movedIndex, to: storedItems.endIndex)
        }
        return true
    }

    /// Remove an item from the deque.
    /// - Parameter item: The item to remove.
    func remove(_ item: PlayerItem) {
        storedItems.removeAll { $0 === item }
    }

    /// Remove all items in the deque.
    func removeAllItems() {
        storedItems.removeAll()
    }
}

public extension Player {
    internal static let startTimeThreshold: TimeInterval = 3

    private func canReturn(before index: Int?, in items: Deque<PlayerItem>, streamType: StreamType) -> Bool {
        if configuration.isSmartNavigationEnabled && streamType == .onDemand {
            return true
        }
        else {
            return Self.canReturnToItem(before: index, in: items)
        }
    }

    /// Check whether returning to the previous content is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPrevious() -> Bool {
        canReturn(before: currentIndex, in: storedItems, streamType: streamType)
    }

    private func isFarFromStartTime() -> Bool {
        time.isValid && timeRange.isValid && (time - timeRange.start).seconds >= Self.startTimeThreshold
    }

    private func shouldSeekToStartTime() -> Bool {
        guard configuration.isSmartNavigationEnabled else { return false }
        return (streamType == .onDemand && isFarFromStartTime()) || !canReturnToPreviousItem()
    }

    /// Return to the previous content.
    func returnToPrevious() {
        if shouldSeekToStartTime() {
            seek(near(.zero))
        }
        else {
            returnToPreviousItem()
        }
    }

    /// Check whether moving to the next content is possible.`
    /// - Returns: `true` if possible.
    func canAdvanceToNext() -> Bool {
        canAdvanceToNextItem()
    }

    /// Move to the next content.
    func advanceToNext() {
        advanceToNextItem()
    }

    /// Set the index of the current item.
    /// - Parameter index: The index to set.
    func setCurrentIndex(_ index: Int) throws {
        guard index != currentIndex else { return }
        guard (0..<storedItems.count).contains(index) else { throw PlaybackError.itemOutOfBounds }
        let playerItems = AVPlayerItem.playerItems(from: Array(storedItems.suffix(from: index)))
        queuePlayer.replaceItems(with: playerItems)
    }
}

extension Player {
    private static func items(before index: Int?, in items: Deque<PlayerItem>) -> [PlayerItem] {
        guard let index else { return [] }
        let previousIndex = items.index(before: index)
        guard previousIndex >= 0 else { return [] }
        return Array(items.suffix(from: previousIndex))
    }

    private static func items(after index: Int?, in items: Deque<PlayerItem>) -> [PlayerItem] {
        guard let index else { return [] }
        let nextIndex = items.index(after: index)
        guard nextIndex < items.count else { return [] }
        return Array(items.suffix(from: nextIndex))
    }

    private static func canReturnToItem(before index: Int?, in items: Deque<PlayerItem>) -> Bool {
        !Self.items(before: index, in: items).isEmpty
    }

    private static func canAdvanceToItem(after index: Int?, in items: Deque<PlayerItem>) -> Bool {
        !Self.items(after: index, in: items).isEmpty
    }

    /// Check whether returning to the previous item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPreviousItem() -> Bool {
        Self.canReturnToItem(before: currentIndex, in: storedItems)
    }

    /// Return to the previous item in the deque. Skips failed items.
    func returnToPreviousItem() {
        guard canReturnToPreviousItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: returningItems))
    }

    /// Check whether moving to the next item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canAdvanceToNextItem() -> Bool {
        Self.canAdvanceToItem(after: currentIndex, in: storedItems)
    }

    /// Move to the next item in the deque.
    func advanceToNextItem() {
        guard canAdvanceToNextItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: advancingItems))
    }
}

public extension Player {
    private static func smoothPlayerItem(for currentItem: CurrentItem, in items: Deque<PlayerItem>) -> AVPlayerItem? {
        switch currentItem {
        case let .bad(playerItem):
            if let lastItem = items.last, lastItem.matches(playerItem) {
                return nil
            }
            else {
                return playerItem
            }
        case let .good(playerItem):
            return playerItem
        }
    }

    /// Check whether the player has finished playing its content and can be restarted.
    /// - Returns: `true` if possible.
    func canRestart() -> Bool {
        guard !storedItems.isEmpty else { return false }
        return Self.smoothPlayerItem(for: currentItem, in: storedItems) == nil
    }

    /// Restart playback if possible.
    func restart() {
        guard canRestart() else { return }
        try? setCurrentIndex(0)
    }
}

extension Player {
    private final class CurrentTracker {
        private let item: PlayerItem
        private var isEnabled = false
        private var cancellables = Set<AnyCancellable>()

        init(item: PlayerItem, player: Player) {
            self.item = item
            configureTrackingPublisher(player: player)
            configureAssetPublisher(for: item)
        }

        deinit {
            disableAssetIfNeeded()
        }

        private func configureTrackingPublisher(player: Player) {
            player.$isTrackingEnabled
                .sink { [weak self, weak player] enabled in
                    guard let self, let player, self.isEnabled != enabled else { return }
                    self.isEnabled = enabled
                    if enabled {
                        self.enableAsset(for: player)
                    }
                    else {
                        self.disableAsset()
                    }
                }
                .store(in: &cancellables)
        }

        private func configureAssetPublisher(for item: PlayerItem) {
            item.$asset
                .sink { asset in
                    asset.updateMetadata()
                }
                .store(in: &cancellables)
        }

        private func enableAsset(for player: Player) {
            item.asset.enable(for: player)
        }

        private func disableAsset() {
            item.asset.disable()
        }

        private func disableAssetIfNeeded() {
            if isEnabled {
                disableAsset()
            }
        }
    }

    private struct Current: Equatable {
        let item: PlayerItem
        let index: Int
    }

    private struct ItemUpdate {
        let items: Deque<PlayerItem>
        let currentItem: AVPlayerItem?

        func currentIndex() -> Int? {
            items.firstIndex { $0.matches(currentItem) }
        }

        func streamTypePublisher() -> AnyPublisher<StreamType, Never> {
            guard let currentItem else { return Just(.unknown).eraseToAnyPublisher() }
            return currentItem.streamTypePublisher().eraseToAnyPublisher()
        }
    }

    private func configurePlaybackStatePublisher() {
        queuePlayer.playbackStatePublisher()
            .receiveOnMainThread()
            .lane("player_state")
            .assign(to: &$playbackState)
    }

    private func configureChunkDurationPublisher() {
        queuePlayer.chunkDurationPublisher()
            .receiveOnMainThread()
            .lane("player_chunk_duration")
            .assign(to: &$chunkDuration)
    }

    private func configureSeekingPublisher() {
        queuePlayer.seekingPublisher()
            .receiveOnMainThread()
            .lane("player_seeking")
            .assign(to: &$isSeeking)
    }

    private func configureBufferingPublisher() {
        queuePlayer.bufferingPublisher()
            .receiveOnMainThread()
            .lane("player_buffering")
            .assign(to: &$isBuffering)
    }

    private func configureCurrentItemPublisher() {
        queuePlayer.smoothCurrentItemPublisher()
            .receiveOnMainThread()
            .assign(to: &$currentItem)
    }

    private func configureCurrentIndexPublisher() {
        currentPublisher()
            .map(\.?.index)
            .receiveOnMainThread()
            .lane("player_current_index")
            .assign(to: &$currentIndex)
    }

    private func configureCurrentTrackerPublisher() {
        currentPublisher()
            .map { [weak self] current in
                guard let self, let current else { return nil }
                return CurrentTracker(item: current.item, player: self)
            }
            .receiveOnMainThread()
            .assign(to: &$currentTracker)
    }

    private func configureControlCenterPublishers() {
        configureControlCenterPublisher()
        configureControlCenterCommandAvailabilityPublisher()
    }

    private func configureControlCenterPublisher() {
        Publishers.CombineLatest(
            nowPlayingInfoMetadataPublisher(),
            queuePlayer.nowPlayingInfoPlaybackPublisher()
        )
        .receiveOnMainThread()
        .lane("control_center_update")
        .sink { [weak self] nowPlayingInfoMetadata, nowPlayingInfoPlayback in
            self?.updateControlCenter(
                nowPlayingInfo: nowPlayingInfoMetadata.merging(nowPlayingInfoPlayback) { _, new in new }
            )
        }
        .store(in: &cancellables)
    }

    private func configureControlCenterCommandAvailabilityPublisher() {
        itemUpdatePublisher()
            .map { update in
                Publishers.CombineLatest3(
                    Just(update.items),
                    Just(update.currentIndex()),
                    update.streamTypePublisher()
                )
            }
            .switchToLatest()
            .sink { [weak self] items, index, streamType in
                guard let self else { return }
                let areSkipsEnabled = items.count <= 1 && streamType != .live
                self.nowPlayingSession.remoteCommandCenter.skipBackwardCommand.isEnabled = areSkipsEnabled
                self.nowPlayingSession.remoteCommandCenter.skipForwardCommand.isEnabled = areSkipsEnabled
                self.nowPlayingSession.remoteCommandCenter.previousTrackCommand.isEnabled = self.canReturn(before: index, in: items, streamType: streamType)
                self.nowPlayingSession.remoteCommandCenter.nextTrackCommand.isEnabled = Self.canAdvanceToItem(after: index, in: items)
            }
            .store(in: &cancellables)
    }

    private func configureQueueUpdatePublisher() {
        assetsPublisher()
            .withPrevious()
            .map { [queuePlayer] sources in
                AVPlayerItem.playerItems(
                    for: sources.current,
                    replacing: sources.previous ?? [],
                    currentItem: queuePlayer.currentItem
                )
            }
            .receiveOnMainThread()
            .sink { [queuePlayer] items in
                queuePlayer.replaceItems(with: items)
            }
            .store(in: &cancellables)
    }

    private func assetsPublisher() -> AnyPublisher<[any Assetable], Never> {
        $storedItems
            .map { items in
                Publishers.AccumulateLatestMany(items.map { item in
                    item.$asset
                })
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    private func configureExternalPlaybackPublisher() {
        queuePlayer.publisher(for: \.isExternalPlaybackActive)
            .receiveOnMainThread()
            .assign(to: &$isExternalPlaybackActive)
    }

    private func configureMediaTypePublisher() {
        queuePlayer.mediaTypePublisher()
            .receiveOnMainThread()
            .assign(to: &$mediaType)
    }

    private func itemUpdatePublisher() -> AnyPublisher<ItemUpdate, Never> {
        Publishers.CombineLatest($storedItems, $currentItem)
            .map { items, currentItem in
                let playerItem = Self.smoothPlayerItem(for: currentItem, in: items)
                return ItemUpdate(items: items, currentItem: playerItem)
            }
            .eraseToAnyPublisher()
    }

    private func currentPublisher() -> AnyPublisher<Current?, Never> {
        itemUpdatePublisher()
            .map { update in
                guard let currentIndex = update.currentIndex() else { return nil }
                return .init(item: update.items[currentIndex], index: currentIndex)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func nowPlayingInfoMetadataPublisher() -> AnyPublisher<NowPlaying.Info, Never> {
        currentPublisher()
            .map { current in
                guard let current else {
                    return Just(NowPlaying.Info()).eraseToAnyPublisher()
                }
                return current.item.$asset
                    .map { $0.nowPlayingInfo() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates { lhs, rhs in
                // swiftlint:disable:next legacy_objc_type
                NSDictionary(dictionary: lhs).isEqual(to: rhs)
            }
            .eraseToAnyPublisher()
    }
}

extension Player {
    private func playRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.playCommand) { [weak self] _ in
            self?.play()
            return .success
        }
    }

    private func pauseRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.pauseCommand) { [weak self] _ in
            self?.pause()
            return .success
        }
    }

    private func togglePlayPauseRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.togglePlayPauseCommand) { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
    }

    private func previousTrackRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.previousTrackCommand.isEnabled = false
        return nowPlayingSession.remoteCommandCenter.register(command: \.previousTrackCommand) { [weak self] _ in
            self?.returnToPrevious()
            return .success
        }
    }

    private func nextTrackRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.nextTrackCommand.isEnabled = false
        return nowPlayingSession.remoteCommandCenter.register(command: \.nextTrackCommand) { [weak self] _ in
            self?.advanceToNext()
            return .success
        }
    }

    private func changePlaybackPositionRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.changePlaybackPositionCommand) { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(near(.init(seconds: positionEvent.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))))
            return .success
        }
    }

    private func skipBackwardRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.skipBackwardCommand.isEnabled = false
        nowPlayingSession.remoteCommandCenter.skipBackwardCommand.preferredIntervals = [.init(value: configuration.backwardSkipInterval)]
        return nowPlayingSession.remoteCommandCenter.register(command: \.skipBackwardCommand) { [weak self] _ in
            self?.skipBackward()
            return .success
        }
    }

    private func skipForwardRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.skipForwardCommand.isEnabled = false
        nowPlayingSession.remoteCommandCenter.skipForwardCommand.preferredIntervals = [.init(value: configuration.forwardSkipInterval)]
        return nowPlayingSession.remoteCommandCenter.register(command: \.skipForwardCommand) { [weak self] _ in
            self?.skipForward()
            return .success
        }
    }

    private func installRemoteCommands() {
        commandRegistrations = [
            playRegistration(),
            pauseRegistration(),
            togglePlayPauseRegistration(),
            previousTrackRegistration(),
            nextTrackRegistration(),
            changePlaybackPositionRegistration(),
            skipBackwardRegistration(),
            skipForwardRegistration()
        ]
    }

    private func uninstallRemoteCommands() {
        commandRegistrations.forEach { registration in
            nowPlayingSession.remoteCommandCenter.unregister(registration)
        }
        commandRegistrations = []
    }

    private func updateControlCenter(nowPlayingInfo: NowPlaying.Info) {
        if !nowPlayingInfo.isEmpty {
            if nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo == nil {
                uninstallRemoteCommands()
                installRemoteCommands()
            }
            nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
        else {
            uninstallRemoteCommands()
            nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo = nil
        }
    }
}
