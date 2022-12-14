//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import DequeModule
import TimelaneCombine

/// An audio / video player maintaining its items as a double-ended queue (deque).
@MainActor
public final class Player: ObservableObject, Equatable {
    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle

    /// Returns whether the player is currently buffering.
    @Published public private(set) var isBuffering = false

    /// Returns whether the player is currently seeking to another position.
    @Published public private(set) var isSeeking = false

    /// The current item in the queue.
    @Published public private(set) var currentItem: PlayerItem?

    /// Available time range. `.invalid` when not known.
    @Published public private(set) var timeRange: CMTimeRange = .invalid

    /// Duration of a chunk for the currently played item.
    @Published public private(set) var chunkDuration: CMTime = .invalid

    @Published private var storedItems: Deque<PlayerItem>
    @Published private var itemDuration: CMTime = .indefinite

    /// Current time.
    public var time: CMTime {
        rawPlayer.currentTime()
    }

    /// Raw player used for playback.
    let rawPlayer: RawPlayer

    private let configuration: PlayerConfiguration
    private var cancellables = Set<AnyCancellable>()

    /// The type of stream currently played.
    public var streamType: StreamType {
        guard timeRange.isValid, itemDuration.isValid else { return .unknown }
        if timeRange.isEmpty {
            return .live
        }
        else {
            if itemDuration.isIndefinite {
                return .dvr
            }
            else {
                return itemDuration == .zero ? .live : .onDemand
            }
        }
    }

    /// Create a player with a given item queue.
    /// - Parameters:
    ///   - items: The items to be queued initially.
    ///   - configuration: A closure in which the player can be configured.
    public init(items: [PlayerItem] = [], configuration: (inout PlayerConfiguration) -> Void = { _ in }) {
        rawPlayer = RawPlayer(items: items.map { $0.source.playerItem() })
        self.configuration = Self.configure(with: configuration)
        storedItems = Deque(items)

        configurePlaybackStatePublisher()
        configureCurrentItemTimeRangePublisher()
        configureCurrentItemDurationPublisher()
        configureChunkDurationPublisher()
        configureSeekingPublisher()
        configureBufferingPublisher()
        configureCurrentItemPublisher()
        configureRawPlayerUpdatePublisher()
    }

    /// Create a player with a single item in its queue.
    /// - Parameters:
    ///   - item: The item to queue.
    ///   - configuration: A closure in which the player can be configured.
    public convenience init(item: PlayerItem, configuration: (inout PlayerConfiguration) -> Void = { _  in }) {
        self.init(items: [item], configuration: configuration)
    }

    public nonisolated static func == (lhs: Player, rhs: Player) -> Bool {
        lhs === rhs
    }

    private static func configure(with configuration: (inout PlayerConfiguration) -> Void) -> PlayerConfiguration {
        var playerConfiguration = PlayerConfiguration()
        configuration(&playerConfiguration)
        return playerConfiguration
    }

    /// Return the player items with which the queue player must be filled.
    /// - Parameters:
    ///   - items: The updated item list.
    ///   - previousItems: The previous item list, if any.
    ///   - player: The queue player.
    private static func queuePlayerItems(
        _ items: Deque<PlayerItem>,
        from previousItems: Deque<PlayerItem>?,
        in player: RawPlayer
    ) -> [PlayerItem] {
        guard let currentItem = player.currentItem else { return Array(items) }

        // Current item found in the updated list. Return updated items from there.
        if let currentIndex = items.firstIndex(where: { $0.matches(currentItem) }) {
            return Array(items.suffix(from: currentIndex))
        }
        // Current item not found in the updated list. Locate a common item which was previously located after the
        // current item and, if any is found, return updated items from there.
        else if let previousItems {
            let previousQueueItems = queuePlayerItems(previousItems, from: nil, in: player)
            guard let commonIndex = items.firstIndex(where: { previousQueueItems.contains($0) }) else {
                return Array(items)
            }
            return Array(items.suffix(from: commonIndex))
        }
        else {
            return Array(items)
        }
    }

    /// Resume playback.
    public func play() {
        rawPlayer.play()
    }

    /// Pause playback.
    public func pause() {
        rawPlayer.pause()
    }

    /// Toggle playback between play and pause.
    public func togglePlayPause() {
        if rawPlayer.rate != 0 {
            rawPlayer.pause()
        }
        else {
            rawPlayer.play()
        }
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    ///   - completionHandler: A completion handler called when seeking ends.
    public func seek(
        to time: CMTime,
        toleranceBefore: CMTime = .positiveInfinity,
        toleranceAfter: CMTime = .positiveInfinity,
        completionHandler: @escaping (Bool) -> Void = { _ in }
    ) {
        rawPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    /// - Returns: `true` if seeking was successful.
    @discardableResult
    public func seek(
        to time: CMTime,
        toleranceBefore: CMTime = .positiveInfinity,
        toleranceAfter: CMTime = .positiveInfinity
    ) async -> Bool {
        await rawPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    /// Return whether the current player item player can be returned to live conditions.
    /// - Returns: `true` if skipping to live conditions is possible.
    public func canSkipToLive() -> Bool {
        canSkipToLive(from: time)
    }

    /// Return whether the current player item player can be returned to live conditions, starting from the specified
    /// time.
    /// - Parameter time: The time.
    /// - Returns: `true` if skipping to live conditions is possible.
    public func canSkipToLive(from time: CMTime) -> Bool {
        guard streamType == .dvr, timeRange.isValid else { return false }
        return chunkDuration.isValid && time < timeRange.end - chunkDuration
    }

    /// Return the current item to live conditions. Does nothing if the current item is not a livestream or does not
    /// support DVR.
    /// - Parameter completionHandler: A completion handler called when skipping ends.
    /// - Returns: `true` if skipping to live conditions is possible.
    @discardableResult
    public func skipToLive(completionHandler: @escaping (Bool) -> Void = { _ in }) -> Bool {
        guard canSkipToLive(), timeRange.isValid else { return false }
        rawPlayer.seek(
            to: timeRange.end,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity
        ) { [weak self] finished in
            self?.play()
            completionHandler(finished)
        }
        return true
    }

    /// Return the current item to live conditions, resuming playback if needed. Does nothing if the current item is
    ///  not a livestream or does not support DVR.
    /// - Returns: `true` if skipping to live conditions is possible.
    @discardableResult
    public func skipToLive() async -> Bool {
        guard canSkipToLive(), timeRange.isValid else {
            return false
        }
        let seeked = await rawPlayer.seek(
            to: timeRange.end,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity
        )
        rawPlayer.play()
        return seeked
    }

    /// Return a publisher periodically emitting the current time while the player is active. Emits the current time
    /// also on subscription.
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    public func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: rawPlayer, interval: interval, queue: queue)
    }

    /// Return a publisher emitting when traversing the specified times during normal playback.
    /// - Parameters:
    ///   - times: The times to observe.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    public func boundaryTimePublisher(for times: [CMTime], queue: DispatchQueue = .main) -> AnyPublisher<Void, Never> {
        Publishers.BoundaryTimePublisher(for: rawPlayer, times: times, queue: queue)
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
        guard let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) else { return [] }
        return Array(storedItems.prefix(upTo: currentIndex))
    }

    /// Return the list of items to be loaded to return to the previous (playable) item.
    private var returningItems: [PlayerItem] {
        guard let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) else { return [] }
        let previousIndex = storedItems.index(before: currentIndex)
        guard previousIndex >= 0 else { return [] }
        return Array(storedItems.suffix(from: previousIndex))
    }

    /// Items past the current item (not included).
    /// - Returns: Items.
    var nextItems: [PlayerItem] {
        guard let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) else {
            return Array(storedItems)
        }
        return Array(storedItems.suffix(from: currentIndex).dropFirst())
    }

    /// Return the list of items to be loaded to advance to the next (playable) item.
    private var advancingItems: [PlayerItem] {
        guard let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) else { return [] }
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

    /// Check whether returning to the previous item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPreviousItem() -> Bool {
        !returningItems.isEmpty
    }

    /// Return to the previous item in the deque. Skips failed items.
    /// - Returns: `true` if not possible.
    @discardableResult
    func returnToPreviousItem() -> Bool {
        guard canReturnToPreviousItem() else { return false}
        let playerItems = returningItems.map { $0.source.playerItem() }
        rawPlayer.replaceItems(with: playerItems)
        return true
    }

    /// Check whether moving to the next item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canAdvanceToNextItem() -> Bool {
        !advancingItems.isEmpty
    }

    /// Move to the next item in the deque.
    /// - Returns: `true` if not possible.
    @discardableResult
    func advanceToNextItem() -> Bool {
        guard canAdvanceToNextItem() else { return false }
        let playerItems = advancingItems.map { $0.source.playerItem() }
        rawPlayer.replaceItems(with: playerItems)
        return true
    }
}

private extension Player {
    private func configurePlaybackStatePublisher() {
        rawPlayer.playbackStatePublisher()
            .receiveOnMainThread()
            .lane("player_state")
            .assign(to: &$playbackState)
    }

    private func configureCurrentItemTimeRangePublisher() {
        rawPlayer.currentItemTimeRangePublisher()
            .receiveOnMainThread()
            .lane("player_time_range")
            .assign(to: &$timeRange)
    }

    private func configureCurrentItemDurationPublisher() {
        rawPlayer.currentItemDurationPublisher()
            .receiveOnMainThread()
            .lane("player_item_duration")
            .assign(to: &$itemDuration)
    }

    private func configureChunkDurationPublisher() {
        rawPlayer.publisher(for: \.currentItem)
            .map { item -> AnyPublisher<CMTime, Never> in
                guard let item else { return Just(.invalid).eraseToAnyPublisher() }
                return item.asset.propertyPublisher(.minimumTimeOffsetFromLive)
                    .map { CMTimeMultiplyByRatio($0, multiplier: 1, divisor: 3) }       // The minimum offset represents 3 chunks
                    .replaceError(with: .invalid)
                    .prepend(.invalid)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receiveOnMainThread()
            .lane("player_chunk_duration")
            .assign(to: &$chunkDuration)
    }

    private func configureSeekingPublisher() {
        rawPlayer.seekingPublisher()
            .receiveOnMainThread()
            .lane("player_seeking")
            .assign(to: &$isSeeking)
    }

    private func configureBufferingPublisher() {
        rawPlayer.bufferingPublisher()
            .receiveOnMainThread()
            .lane("player_buffering")
            .assign(to: &$isBuffering)
    }

    private func configureCurrentItemPublisher() {
        Publishers.CombineLatest($storedItems, rawPlayer.publisher(for: \.currentItem))
            .map { storedItems, currentItem in
                storedItems.first { $0.matches(currentItem) }
            }
            .removeDuplicates()
            .receiveOnMainThread()
            .lane("player_current_item")
            .assign(to: &$currentItem)
    }

    private func configureRawPlayerUpdatePublisher() {
        $storedItems
            .withPrevious()
            .map { [rawPlayer] items in
                let queueItems = Self.queuePlayerItems(items.current, from: items.previous, in: rawPlayer)
                return Publishers.AccumulateLatestMany(queueItems.map { item in
                    item.$source.map { $0.playerItem() }
                })
            }
            .switchToLatest()
            .receiveOnMainThread()
            .sink { [rawPlayer] playerItems in
                rawPlayer.replaceItems(with: playerItems)
            }
            .store(in: &cancellables)
    }
}
