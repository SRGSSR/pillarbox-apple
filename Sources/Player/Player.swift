//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

/// Audio / video player.
@MainActor
public final class Player: ObservableObject {
    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle
    /// Current playback properties.
    @Published private var playbackProperties: PlaybackProperties = .empty

    /// A value in 0...1 describing the current playback progress.
    public var progress: Float {
        playbackProperties.pulse?.progress ?? 0
    }

    public var time: CMTime? {
        playbackProperties.pulse?.time
    }

    public var timeRange: CMTimeRange? {
        playbackProperties.pulse?.timeRange
    }

    /// Progress which the player is reaching.
    @Published public var targetProgress: Float = 0 {
        willSet {
            guard let time = playbackProperties.pulse?.time(forProgress: newValue),
                    time.isNumeric else {
                return
            }
            seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { _ in }
        }
    }

    let dequeuePlayer: DequeuePlayer

    private let configuration: PlayerConfiguration

    /// The items currently queued by the player.
    public var items: [AVPlayerItem] {
        dequeuePlayer.items()
    }

    /// The type of stream currently played.
    public var streamType: StreamType {
        StreamType.streamType(for: playbackProperties.pulse)
    }

    /// Create a player with a given item queue.
    /// - Parameter items: The items to be queued initially.
    public init(items: [AVPlayerItem] = [], configuration: (inout PlayerConfiguration) -> Void = { _ in }) {
        dequeuePlayer = DequeuePlayer(items: items)
        self.configuration = Self.configure(with: configuration)

        dequeuePlayer.playbackStatePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$playbackState)
        dequeuePlayer.playbackPropertiesPublisher(configuration: self.configuration)
            .receive(on: DispatchQueue.main)
            .assign(to: &$playbackProperties)
        $playbackProperties
            .map { $0.targetProgress ?? 0 }
            .removeDuplicates()
            .assign(to: &$targetProgress)
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
        dequeuePlayer.insert(item, after: afterItem)
    }

    /// Append an item to the queue.
    /// - Parameter item: The item to append.
    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    /// Remove an item from the queue.
    /// - Parameter item: The item to remove.
    public func remove(_ item: AVPlayerItem) {
        dequeuePlayer.remove(item)
    }

    /// Remove all items from the queue.
    public func removeAllItems() {
        dequeuePlayer.removeAllItems()
    }

    /// Resume playback.
    public func play() {
        dequeuePlayer.play()
    }

    /// Pause playback.
    public func pause() {
        dequeuePlayer.pause()
    }

    /// Toggle playback between play and pause.
    public func togglePlayPause() {
        if dequeuePlayer.rate != 0 {
            dequeuePlayer.pause()
        }
        else {
            dequeuePlayer.play()
        }
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    ///   - completionHandler: A completion handler called when seeking ends.
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        dequeuePlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    /// Seek to a given location.
    /// - Parameters:
    ///   - time: The time to seek to.
    ///   - toleranceBefore: Tolerance before the desired position.
    ///   - toleranceAfter: Tolerance after the desired position.
    /// - Returns: `true` if seeking was successful.
    @discardableResult
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) async -> Bool {
        await dequeuePlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    /// Create a publisher periodically emitting the current time while the player is active.
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted.
    ///   - queue: The queue on which events are received.
    /// - Returns: The publisher.
    public func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: dequeuePlayer, interval: interval, queue: queue)
    }
}
