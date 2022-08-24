//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

/// Audio and video player.
@MainActor
public final class Player: ObservableObject {
    /// The current player state.
    @Published public private(set) var state: State = .idle
    /// Current player properties.
    @Published public private(set) var properties: Properties

    /// A progress value in 0...1 which the player should reach.
    @Published public var targetProgress: Float = 0 {
        willSet {
            let time = properties.playback.time(forProgress: newValue.clamped(to: 0...1))
            seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { _ in }
        }
    }

    let systemPlayer: SystemPlayer

    /// The items currently queued by the player.
    public var items: [AVPlayerItem] {
        systemPlayer.items()
    }

    /// Create a player with a given item queue.
    /// - Parameter items: The items to be queued initially.
    public init(items: [AVPlayerItem] = []) {
        systemPlayer = SystemPlayer(items: items)
        properties = .empty(for: systemPlayer)

        Self.statePublisher(for: systemPlayer)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
        Self.propertiesPublisher(for: systemPlayer)
            .receive(on: DispatchQueue.main)
            .assign(to: &$properties)
        $properties
            .map { $0.targetProgress ?? $0.progress }
            .removeDuplicates()
            .assign(to: &$targetProgress)
    }

    /// Create a player with a single item in its queue.
    /// - Parameter item: The item to queue.
    public convenience init(item: AVPlayerItem) {
        self.init(items: [item])
    }

    /// Insert an item into the queue.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which the new item must be inserted. If `nil` the item is appended.
    public func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        systemPlayer.insert(item, after: afterItem)
    }

    /// Append an item to the queue.
    /// - Parameter item: The item to append.
    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    /// Remove an item from the queue.
    /// - Parameter item: The item to remove.
    public func remove(_ item: AVPlayerItem) {
        systemPlayer.remove(item)
    }

    /// Remove all items from the queue.
    public func removeAllItems() {
        systemPlayer.removeAllItems()
    }

    /// Resume playback.
    public func play() {
        systemPlayer.play()
    }

    /// Pause playback.
    public func pause() {
        systemPlayer.pause()
    }

    /// Toggle playback between play and pause.
    public func togglePlayPause() {
        if systemPlayer.rate != 0 {
            systemPlayer.pause()
        }
        else {
            systemPlayer.play()
        }
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    ///   - completionHandler: A completion handler called when seeking ends.
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        systemPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    /// - Returns: `true` if seeking was successful.
    @discardableResult
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) async -> Bool {
        await systemPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    static func periodicTimePublisher(for player: AVPlayer, interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(player: player, interval: interval, queue: queue)
            .removeDuplicates(by: Time.close(within: 0.1))
            .eraseToAnyPublisher()
    }

    /// Create a publisher periodically emitting the current time while the player is active.
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted.
    ///   - queue: The queue on which events are received.
    /// - Returns: The publisher.
    public func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Self.periodicTimePublisher(for: systemPlayer, interval: interval, queue: queue)
    }
}
