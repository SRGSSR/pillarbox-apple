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
public final class Player: ObservableObject {
    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle

    /// States whether the player is currently buffering.
    @Published public var isBuffering = false

    /// Current playback progress.
    @Published public var progress: PlaybackProgress = .none {
        willSet {
            guard configuration.seekBehavior == .immediate
                    || (!newValue.isInteracting && progress.isInteracting) else {
                return
            }

            guard let progress = newValue.value, let time = pulse?.time(forProgress: progress) else {
                return
            }
            seek(to: time)
        }
    }

    @Published private var pulse: Pulse?
    @Published private var seeking = false

    /// Current time.
    public var time: CMTime? {
        pulse?.time
    }

    /// Available time range.
    public var timeRange: CMTimeRange? {
        pulse?.timeRange
    }

    /// Raw player used for playback.
    public let rawPlayer: DequePlayer

    private let configuration: PlayerConfiguration
    private var storedItems: Deque<AVPlayerItem>

    /// The type of stream currently played.
    public var streamType: StreamType {
        StreamType.streamType(for: pulse)
    }

    /// Create a player with a given item queue.
    /// - Parameter items: The items to be queued initially.
    public init(items: [AVPlayerItem] = [], configuration: (inout PlayerConfiguration) -> Void = { _ in }) {
        rawPlayer = DequePlayer(items: items.removeDuplicates())
        self.configuration = Self.configure(with: configuration)
        storedItems = Deque(items)

        rawPlayer.playbackStatePublisher()
            .receive(on: DispatchQueue.main)
            .lane("player_state")
            .assign(to: &$playbackState)
        rawPlayer.pulsePublisher(configuration: self.configuration)
            .receive(on: DispatchQueue.main)
            .lane("player_pulse") { output in
                guard let output else { return "nil" }
                return String(describing: output)
            }
            .assign(to: &$pulse)
        rawPlayer.seekingPublisher()
            .receive(on: DispatchQueue.main)
            .lane("player_seeking")
            .assign(to: &$seeking)

        rawPlayer.bufferingPublisher()
            .receive(on: DispatchQueue.main)
            .lane("player_buffering")
            .assign(to: &$isBuffering)

        // Update progress from pulse information, except when the player is seeking or the progress updated
        // interactively.
        Publishers.CombineLatest($pulse, $seeking)
            .filter { !$0.1 }
            .map(\.0)
            .weakCapture(self, at: \.progress)
            .filter { !$1.isInteracting }
            .map { PlaybackProgress(value: $0.0?.progress, isInteracting: false) }
            .removeDuplicates()
            .lane("player_progress")
            .assign(to: &$progress)
    }

    /// Create a player with a single item in its queue.
    /// - Parameter item: The item to queue.
    public convenience init(item: AVPlayerItem, configuration: (inout PlayerConfiguration) -> Void = { _  in }) {
        self.init(items: [item], configuration: configuration)
    }

    private static func configure(with configuration: (inout PlayerConfiguration) -> Void) -> PlayerConfiguration {
        var playerConfiguration = PlayerConfiguration()
        configuration(&playerConfiguration)
        return playerConfiguration
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
    public func seek(to time: CMTime, toleranceBefore: CMTime = .positiveInfinity, toleranceAfter: CMTime = .positiveInfinity, completionHandler: @escaping (Bool) -> Void = { _ in }) {
        rawPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    /// - Returns: `true` if seeking was successful.
    @discardableResult
    public func seek(to time: CMTime, toleranceBefore: CMTime = .positiveInfinity, toleranceAfter: CMTime = .positiveInfinity) async -> Bool {
        await rawPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    /// Return a publisher periodically emitting the current time while the player is active.
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
    var items: [AVPlayerItem] {
        Array(storedItems)
    }

    /// The current item in the queue.
    var currentItem: AVPlayerItem? {
        rawPlayer.currentItem
    }

    /// Items before the current item (not included).
    /// - Returns: Items.
    var previousItems: [AVPlayerItem] {
        guard let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) else {
            return Array(storedItems)
        }
        return Array(storedItems.prefix(upTo: currentIndex))
    }

    /// Items past the current item (not included).
    /// - Returns: Items.
    var nextItems: [AVPlayerItem] {
        Array(rawPlayer.items().dropFirst())
    }

    /// Check whether an item can be inserted before another item. An item can appear once at most in a deque.
    /// - Parameters:
    ///   - item: The item to be tested.
    ///   - beforeItem: The item before which insertion should take place. Pass `nil` to check insertion at the front
    ///     of the deque.
    /// - Returns: `true` iff the tested item can be inserted.
    func canInsert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) -> Bool {
        guard let beforeItem else { return true }
        return storedItems.contains(beforeItem) && !storedItems.contains(item)
    }

    /// Insert an item before another item. Does nothing if the item already belongs to the deque.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the deque.
    func insert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
        guard canInsert(item, before: beforeItem) else { return }
        if let beforeItem {
            guard let index = storedItems.firstIndex(of: beforeItem) else { return }
            storedItems.insert(item, at: index)
            if index != 0 {
                let afterIndex = storedItems.index(before: index)
                rawPlayer.insert(item, after: storedItems[afterIndex])
            }
        }
        else {
            storedItems.prepend(item)
        }
    }

    /// Check whether an item can be inserted after another item. An item can appear once at most in a deque.
    /// - Parameters:
    ///   - item: The item to be tested.
    ///   - afterItem: The item after which insertion should take place. Pass `nil` to check insertion at the back
    ///     of the deque. If this item does not exist the method does nothing.
    /// - Returns: `true` iff the tested item can be inserted.
    func canInsert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) -> Bool {
        guard let afterItem else { return true }
        return storedItems.contains(afterItem) && !storedItems.contains(item)
    }

    /// Insert an item after another item. Does nothing if the item already belongs to the deque.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the back of
    ///     the deque. If this item does not exist the method does nothing.
    func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        guard canInsert(item, after: afterItem) else { return }
        if let afterItem {
            guard let index = storedItems.firstIndex(of: afterItem) else { return }
            storedItems.insert(item, at: storedItems.index(after: index))
            rawPlayer.insert(item, after: afterItem)
        }
        else {
            storedItems.append(item)
            rawPlayer.insert(item, after: nil)
        }
    }

    /// Prepend an item to the deque.
    /// - Parameter item: The item to prepend.
    func prepend(_ item: AVPlayerItem) {
        insert(item, before: nil)
    }

    /// Append an item to the deque.
    /// - Parameter item: The item to append.
    func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    /// Check whether an item can be moved before another item. `
    /// - Parameters:
    ///   - item: The item to move. The method returns `false` if the item does not belong to the deque.
    ///   - beforeItem: The item before which the moved item must be inserted. Pass `nil` to insert the item at the
    ///     front of the deque. If the item does not belong to the deque the method returns `false`.
    /// - Returns: `true` if the item can be moved. Returns `false` if the item cannot be moved or is already at the
    ///   desired location.
    func canMove(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) -> Bool {
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
    func move(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
        guard canMove(item, before: beforeItem) else { return }
        remove(item)
        insert(item, before: beforeItem)
    }

    /// Check whether an item can be moved after another item. `
    /// - Parameters:
    ///   - item: The item to move. The method returns `false` if the item does not belong to the deque.
    ///   - afterItem: The item after which the moved item must be inserted. Pass `nil` to insert the item at the
    ///     back of the deque. If the item does not belong to the deque the method returns `false`.
    /// - Returns: `true` if the item can be moved. Returns `false` if the item cannot be moved or is already at the
    ///   desired location.
    func canMove(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) -> Bool {
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
    func move(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        guard canMove(item, after: afterItem) else { return }
        remove(item)
        insert(item, after: afterItem)
    }

    /// Remove an item from the deque.
    /// - Parameter item: The item to remove.
    func remove(_ item: AVPlayerItem) {
        storedItems.removeAll { $0 === item }
        rawPlayer.remove(item)
    }

    /// Remove all items in the deque.
    func removeAllItems() {
        storedItems.removeAll()
        rawPlayer.removeAllItems()
    }

    // TODO: canReturn?

    /// Return to the previous item in the deque.
    func returnToPreviousItem() {
    }

    // TODO: canAdvance?

    /// Move to the next item in the deque.
    func advanceToNextItem() {
        rawPlayer.advanceToNextItem()
    }
}

