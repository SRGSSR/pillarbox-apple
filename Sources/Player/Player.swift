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

    /// Returns whether the player is currently buffering.
    @Published public private(set) var isBuffering = false

    /// Returns whether the player is currently seeking to another position.
    @Published public private(set) var isSeeking = false

    /// The index of the current item in the queue.
    @Published public private(set) var currentIndex: Int?

    /// Available time range. `.invalid` when not known.
    @Published public private(set) var timeRange: CMTimeRange = .invalid

    /// Duration of a chunk for the currently played item.
    @Published public private(set) var chunkDuration: CMTime = .invalid

    /// Indicates whether the player is currently playing video in external playback mode.
    @Published public private(set) var isExternalPlaybackActive = false

    @Published private var storedItems: Deque<PlayerItem>
    @Published private var itemDuration: CMTime = .indefinite

    /// Current time.
    public var time: CMTime {
        queuePlayer.currentTime().clamped(to: timeRange)
    }

    let queuePlayer = QueuePlayer()
    private let nowPlayingSession: MPNowPlayingSession

    public let configuration: PlayerConfiguration
    private var cancellables = Set<AnyCancellable>()

    private var commandRegistrations: [any RemoteCommandRegistrable] = []

    // Skips
    var backwardSkipTime: CMTime {
        CMTime(seconds: -configuration.backwardSkipInterval, preferredTimescale: 1)
    }
    var forwardSkipTime: CMTime {
        CMTime(seconds: configuration.forwardSkipInterval, preferredTimescale: 1)
    }

    /// The type of stream currently played.
    public var streamType: StreamType {
        StreamType(for: timeRange, itemDuration: itemDuration)
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
        configureCurrentItemTimeRangePublisher()
        configureCurrentItemDurationPublisher()
        configureChunkDurationPublisher()
        configureSeekingPublisher()
        configureBufferingPublisher()
        configureCurrentIndexPublisher()
        configureControlCenterPublisher()
        configureQueueUpdatePublisher()
        configureExternalPlaybackPublisher()

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
        guard timeRange.isValid, !timeRange.isEmpty else { return false }
        return timeRange.start <= time && time <= timeRange.end
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    ///   - isSmooth: Set to `true` to enable smooth seeking
    ///   - completion: A completion called when seeking ends. The provided Boolean informs
    ///     whether the seek could finish without being cancelled.
    func seek(
        to time: CMTime,
        toleranceBefore: CMTime = .positiveInfinity,
        toleranceAfter: CMTime = .positiveInfinity,
        isSmooth: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        let time = time.clamped(to: timeRange)
        guard time.isValid else {
            completion(true)
            return
        }
        queuePlayer.seek(
            to: time,
            toleranceBefore: toleranceBefore,
            toleranceAfter: toleranceAfter,
            isSmooth: isSmooth,
            completionHandler: completion
        )
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    ///   - isSmooth: Set to `true` to enable smooth seeking, preventing unnecessary seek cancellation.
    /// - Returns: `true` if seeking could finish without being cancelled.
    @discardableResult
    func seek(
        to time: CMTime,
        toleranceBefore: CMTime = .positiveInfinity,
        toleranceAfter: CMTime = .positiveInfinity,
        isSmooth: Bool = false
    ) async -> Bool {
        let time = time.clamped(to: timeRange)
        guard time.isValid else { return true }
        return await queuePlayer.seek(
            to: time,
            toleranceBefore: toleranceBefore,
            toleranceAfter: toleranceAfter,
            isSmooth: isSmooth
        )
    }
}

public extension Player {
    /// Return whether the current player item player can be returned to live conditions.
    /// - Returns: `true` if skipping to live conditions is possible.
    func canSkipToLive() -> Bool {
        canSkipToLive(from: time)
    }

    /// Return whether the current player item player can be returned to live conditions, starting from the specified
    /// time.
    /// - Parameter time: The time.
    /// - Returns: `true` if skipping to live conditions is possible.
    func canSkipToLive(from time: CMTime) -> Bool {
        guard streamType == .dvr else { return false }
        return chunkDuration.isValid && time < timeRange.end - chunkDuration
    }

    /// Return the current item to live conditions. Does nothing if the current item is not a livestream or does not
    /// support DVR.
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipToLive(completion: @escaping (Bool) -> Void = { _ in }) {
        let time = timeRange.end.clamped(to: timeRange)
        guard time.isValid else {
            completion(true)
            return
        }
        queuePlayer.seek(
            to: time,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity
        ) { [weak self] finished in
            self?.play()
            completion(finished)
        }
    }

    /// Return the current item to live conditions, resuming playback if needed. Does nothing if the current item is
    /// not a livestream or does not support DVR.
    /// - Returns: `true` if the skip finished without being cancelled.
    @discardableResult
    func skipToLive() async -> Bool {
        let time = timeRange.end.clamped(to: timeRange)
        guard time.isValid else { return true }
        let seeked = await queuePlayer.seek(
            to: time,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity
        )
        queuePlayer.play()
        return seeked
    }
}

public extension Player {
    /// Check whether skipping backward is possible.
    /// - Returns: `true` if possible.
    func canSkipBackward() -> Bool {
        canSkip(withInterval: backwardSkipTime)
    }

    /// Check whether skipping forward is possible.
    /// - Returns: `true` if possible.
    func canSkipForward() -> Bool {
        canSkip(withInterval: forwardSkipTime)
    }

    /// Skip backward.
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipBackward(completion: @escaping (Bool) -> Void = { _ in }) {
        skip(withInterval: backwardSkipTime, completion: completion)
    }

    /// Skip forward.
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipForward(completion: @escaping (Bool) -> Void = { _ in }) {
        skip(withInterval: forwardSkipTime, completion: completion)
    }

    /// Skip backward.
    /// - Returns: `true` if the skip finished without being cancelled.
    @discardableResult
    func skipBackward() async -> Bool {
        await skip(withInterval: backwardSkipTime)
    }

    /// Skip forward.
    /// - Returns: `true` if the skip finished without being cancelled.
    @discardableResult
    func skipForward() async -> Bool {
        await skip(withInterval: forwardSkipTime)
    }

    private func canSkip(withInterval interval: CMTime) -> Bool {
        let currentTime = queuePlayer.targetSeekTime ?? time
        return canSeek(to: currentTime + interval)
    }

    private func skip(withInterval interval: CMTime, completion: @escaping (Bool) -> Void = { _ in }) {
        let currentTime = queuePlayer.targetSeekTime ?? time
        seek(to: currentTime + interval, completion: completion)
    }

    private func skip(withInterval interval: CMTime) async -> Bool {
        let currentTime = queuePlayer.targetSeekTime ?? time
        return await seek(to: currentTime + interval)
    }
}

public extension Player {
    /// Return a publisher periodically emitting the current time while the player is active. Emits the current time
    /// also on subscription.
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
        guard let currentIndex else { return [] }
        let previousIndex = storedItems.index(before: currentIndex)
        guard previousIndex >= 0 else { return [] }
        return Array(storedItems.suffix(from: previousIndex))
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
        guard let currentIndex else { return [] }
        let nextIndex = storedItems.index(after: currentIndex)
        guard nextIndex < storedItems.count else { return [] }
        return Array(storedItems.suffix(from: nextIndex))
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

    /// Check whether returning to the previous content is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPrevious() -> Bool {
        if configuration.isSmartNavigationEnabled && streamType == .onDemand {
            return true
        }
        else {
            return canReturnToPreviousItem()
        }
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
            seek(to: .zero)
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
    /// Check whether returning to the previous item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPreviousItem() -> Bool {
        !returningItems.isEmpty
    }

    /// Return to the previous item in the deque. Skips failed items.
    func returnToPreviousItem() {
        guard canReturnToPreviousItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: returningItems))
    }

    /// Check whether moving to the next item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canAdvanceToNextItem() -> Bool {
        !advancingItems.isEmpty
    }

    /// Move to the next item in the deque.
    func advanceToNextItem() {
        guard canAdvanceToNextItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: advancingItems))
    }
}

extension Player {
    private struct Current: Equatable {
        let item: PlayerItem
        let index: Int
    }

    private func configurePlaybackStatePublisher() {
        queuePlayer.playbackStatePublisher()
            .receiveOnMainThread()
            .lane("player_state")
            .assign(to: &$playbackState)
    }

    private func configureCurrentItemTimeRangePublisher() {
        queuePlayer.currentItemTimeRangePublisher()
            .receiveOnMainThread()
            .lane("player_time_range")
            .assign(to: &$timeRange)
    }

    private func configureCurrentItemDurationPublisher() {
        queuePlayer.currentItemDurationPublisher()
            .receiveOnMainThread()
            .lane("player_item_duration")
            .assign(to: &$itemDuration)
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

    private func configureCurrentIndexPublisher() {
        currentPublisher()
            .map(\.?.index)
            .receiveOnMainThread()
            .lane("player_current_index")
            .assign(to: &$currentIndex)
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

    private func configureQueueUpdatePublisher() {
        sourcesPublisher()
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

    private func sourcesPublisher() -> AnyPublisher<[Source], Never> {
        $storedItems
            .map { items in
                Publishers.AccumulateLatestMany(items.map { item in
                    item.$source
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

    private func currentPublisher() -> AnyPublisher<Current?, Never> {
        Publishers.CombineLatest($storedItems, queuePlayer.publisher(for: \.currentItem))
            .filter { storedItems, currentItem in
                // The current item is automatically set to `nil` when a failure is encountered. If this is the case
                // preserve the previous value, provided the player is loaded with items.
                storedItems.isEmpty || currentItem != nil
            }
            .map { storedItems, currentItem in
                guard let currentIndex = storedItems.firstIndex(where: { $0.matches(currentItem) }) else { return nil }
                return .init(item: storedItems[currentIndex], index: currentIndex)
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
                return current.item.$source
                    .map { $0.asset.nowPlayingInfo() }
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
        nowPlayingSession.remoteCommandCenter.register(command: \.previousTrackCommand) { [weak self] _ in
            self?.returnToPrevious()
            return .success
        }
    }

    private func nextTrackRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.nextTrackCommand) { [weak self] _ in
            self?.advanceToNext()
            return .success
        }
    }

    private func changePlaybackPositionRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.register(command: \.changePlaybackPositionCommand) { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: .init(seconds: positionEvent.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            return .success
        }
    }

    private func skipBackwardRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.skipBackwardCommand.preferredIntervals = [.init(value: configuration.backwardSkipInterval)]
        return nowPlayingSession.remoteCommandCenter.register(command: \.skipBackwardCommand) { [weak self] _ in
            self?.skipBackward()
            return .success
        }
    }

    private func skipForwardRegistration() -> some RemoteCommandRegistrable {
        nowPlayingSession.remoteCommandCenter.skipForwardCommand.preferredIntervals = [.init(value: configuration.backwardSkipInterval)]
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
