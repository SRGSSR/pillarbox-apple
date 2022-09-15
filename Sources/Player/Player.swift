//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import TimelaneCombine

/// Audio / video player.
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
    public let rawPlayer: DequeuePlayer

    private let configuration: PlayerConfiguration

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
        rawPlayer = DequeuePlayer(items: items.removeDuplicates())
        self.configuration = Self.configure(with: configuration)

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

    /// Insert an item into the queue.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which the new item must be inserted. If `nil` the item is appended.
    public func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        guard rawPlayer.canInsert(item, after: afterItem) else { return }
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

    deinit {
        // Further improve deallocation in some cases where `AVQueuePlayer` cannot properly clean everything up.
        rawPlayer.removeAllItems()
    }
}
