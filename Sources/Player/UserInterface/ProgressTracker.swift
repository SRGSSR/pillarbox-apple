//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import SwiftUI

/// An observable object which tracks playback progress.
///
/// Progress trackers can be instantiated in a SwiftUI view hierarchy to trigger local view updates at a specific
/// pace, avoiding unnecessary refreshes in other parts of the view hierarchy that do not need to be periodically
/// refreshed.
public final class ProgressTracker: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// A Boolean describing whether user interaction is currently changing the progress value.
    @Published public var isInteracting = false {
        willSet {
            guard !newValue else { return }
            seek(to: progress, smooth: false)
        }
    }

    /// A Float value representing the amount of content that has been loaded and is available for playback.
    @Published public var buffer: Float = .zero

    @Published private var _progress: Float?

    private let seekBehavior: SeekBehavior

    /// The current progress.
    ///
    /// The returned value might be different from the player progress when interaction takes place.
    ///
    /// This property returns 0 when no progress information is available, which you can check using `isProgressAvailable`.
    public var progress: Float {
        get {
            _progress ?? 0
        }
        set {
            guard _progress != nil else { return }
            _progress = newValue.clamped(to: range)
            guard seekBehavior == .immediate else { return }
            seek(to: newValue, smooth: true)
        }
    }

    /// The time corresponding to the current progress.
    ///
    /// The returned value might be different from the player current time when interaction takes place.
    ///
    /// Non-`nil` returned times are guaranteed to be valid.
    public var time: CMTime? {
        time(forProgress: _progress)
    }

    /// The allowed range for progress values.
    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

    public var isProgressAvailable: Bool {
        _progress != nil
    }

    /// The current time range.
    ///
    /// Non-`nil` returned ranges are guaranteed to be valid.
    public var timeRange: CMTimeRange? {
        guard let timeRange = player?.timeRange, timeRange.isValidAndNotEmpty else { return nil }
        return timeRange
    }

    /// Creates a progress tracker updating its progress at the specified interval.
    /// 
    /// - Parameter interval: The interval at which progress must be updated.
    public init(interval: CMTime, seekBehavior: SeekBehavior = .immediate) {
        self.seekBehavior = seekBehavior
        $player
            .removeDuplicates()
            .map { [$isInteracting] player -> AnyPublisher<Float?, Never> in
                guard let player else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return Publishers.CombineLatest(
                    Self.currentTimePublisher(for: player, interval: interval, isInteracting: $isInteracting),
                    player.queuePlayer.currentItemTimeRangePublisher()
                )
                .map { time, timeRange in
                    Self.progress(for: time, in: timeRange)
                }
                .prepend(Self.progress(for: player.time, in: player.timeRange))
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$_progress)

        $player
            .map { player -> AnyPublisher<Float, Never> in
                guard let player, let item = player.queuePlayer.currentItem else { return Just(.zero).eraseToAnyPublisher() }
                return player.queuePlayer
                    .currentItemLoadedTimeRangePublisher()
                    .map { loadedTimeRange in
                        let totalDuration = item.duration.seconds
                        let durationRatio = loadedTimeRange.end.seconds / totalDuration
                        return Float(durationRatio)
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$buffer)
    }

    private static func currentTimePublisher(
        for player: Player,
        interval: CMTime,
        isInteracting: Published<Bool>.Publisher
    ) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            player.queuePlayer.smoothCurrentTimePublisher(interval: interval, queue: .main),
            isInteracting
        )
        .compactMap { time, isInteracting in
            !isInteracting ? time : nil
        }
        .eraseToAnyPublisher()
    }

    private static func progress(for time: CMTime, in timeRange: CMTimeRange) -> Float? {
        guard time.isValid, timeRange.isValidAndNotEmpty else { return nil }
        return Float((time - timeRange.start).seconds / timeRange.duration.seconds).clamped(to: 0...1)
    }

    private func seek(to progress: Float, smooth: Bool) {
        guard let player, let time = time(forProgress: progress) else { return }
        player.seek(near(time), smooth: smooth)
    }

    private func time(forProgress progress: Float?) -> CMTime? {
        guard let timeRange, let progress else { return nil }
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: Float64(progress))
    }
}

public extension View {
    /// Binds a progress tracker to a player.
    ///
    /// - Parameters:
    ///   - progressTracker: The progress tracker to bind.
    ///   - player: The player to observe.
    func bind(_ progressTracker: ProgressTracker, to player: Player?) -> some View {
        onAppear {
            progressTracker.player = player
        }
        .onChange(of: player) { newValue in
            progressTracker.player = newValue
        }
    }
}
