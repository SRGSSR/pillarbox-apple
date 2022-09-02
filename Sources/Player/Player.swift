//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import TimelaneCombine

/// Audio / video player.
@MainActor
public final class Player: ObservableObject {
    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle
    /// Current pulse.
    @Published private var pulse: Pulse?

    /// Current playback progress.
    @Published public var progress: PlaybackProgress = .empty {
        willSet {
            guard let progress = newValue.value, let time = pulse?.time(forProgress: progress),
                  time.isNumeric else {
                return
            }
            seek(to: time)
        }
    }

    /// Current time.
    public var time: CMTime? {
        pulse?.time
    }

    /// Available time range.
    public var timeRange: CMTimeRange? {
        pulse?.timeRange
    }

    /// Raw player used for playback.
    public let rawPlayer: DequeuePlayer

    private let configuration: PlayerConfiguration
    private let queue = DispatchQueue(label: "ch.srgssr.pillarbox.player")

    /// The items currently queued by the player.
    public var items: [AVPlayerItem] {
        rawPlayer.items()
    }

    /// The type of stream currently played.
    public var streamType: StreamType {
        StreamType.streamType(for: pulse)
    }

    /// Create a player with a given item queue.
    /// - Parameter items: The items to be queued initially.
    public init(items: [AVPlayerItem] = [], configuration: (inout PlayerConfiguration) -> Void = { _ in }) {
        rawPlayer = DequeuePlayer(items: items)
        self.configuration = Self.configure(with: configuration)

        rawPlayer.playbackStatePublisher()
            .receive(on: DispatchQueue.main)
            .lane("player_state")
            .assign(to: &$playbackState)
        rawPlayer.pulsePublisher(configuration: self.configuration, queue: queue)
            .receive(on: DispatchQueue.main)
            .lane("player_pulse")
            .assign(to: &$pulse)
        $pulse
            .weakCapture(self, at: \.progress)
            .filter { !$1.isInteracting }
            .map { PlaybackProgress(value: $0?.progress, isInteracting: $1.isInteracting) }
            .removeDuplicates()
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

    /// Insert an item into the queue.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which the new item must be inserted. If `nil` the item is appended.
    public func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        rawPlayer.insert(item, after: afterItem)
    }

    /// Append an item to the queue.
    /// - Parameter item: The item to append.
    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    /// Remove an item from the queue.
    /// - Parameter item: The item to remove.
    public func remove(_ item: AVPlayerItem) {
        rawPlayer.remove(item)
    }

    /// Remove all items from the queue.
    public func removeAllItems() {
        rawPlayer.removeAllItems()
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

    /// Create a publisher periodically emitting the current time while the player is active.
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted.
    ///   - queue: The queue on which events are received.
    /// - Returns: The publisher.
    public func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: rawPlayer, interval: interval, queue: queue)
    }
}
