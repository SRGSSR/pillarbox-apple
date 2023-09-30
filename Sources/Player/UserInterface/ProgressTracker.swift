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
    @Published public var player: Player? {
        willSet {
            resumePlaybackIfNeeded(with: player)
        }
        didSet {
            guard isInteracting else { return }
            pausePlaybackIfNeeded(with: player)
        }
    }

    /// A Boolean describing whether user interaction is currently changing the progress value.
    @Published public var isInteracting = false {
        willSet {
            if newValue {
                pausePlaybackIfNeeded(with: player)
            }
            else {
                resumePlaybackIfNeeded(with: player)
                seek(to: progress, optimal: false)
            }
        }
    }

    @Published private var _progress: Float?

    private let seekBehavior: SeekBehavior
    private var wasPaused = false

    /// The current progress.
    ///
    /// Returns a value between 0 and 1. The progress might be different from the actual player progress during
    /// user interaction.
    ///
    /// This property returns 0 when no progress information is available. Use `isProgressAvailable` to check whether
    /// progress is available or not.
    public var progress: Float {
        get {
            _progress ?? 0
        }
        set {
            guard _progress != nil else { return }
            _progress = newValue.clamped(to: range)
            guard seekBehavior == .immediate else { return }
            seek(to: newValue, optimal: true)
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
                    player.queuePlayer.propertiesPublisher()
                )
                .map { time, properties in
                    Self.progress(for: time, in: properties.timeProperties.seekableTimeRange)
                }
                .prepend(Self.progress(for: player.time, in: player.timeRange))
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$_progress)
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

    private func seek(to progress: Float, optimal: Bool) {
        guard let player, let time = time(forProgress: progress) else { return }
        if optimal {
            player.seek(to: time)
        }
        else {
            player.seek(near(time), smooth: false)
        }
    }

    private func time(forProgress progress: Float?) -> CMTime? {
        guard let timeRange, let progress else { return nil }
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: Float64(progress))
    }

    private func pausePlaybackIfNeeded(with player: Player?) {
        guard let player, player.playbackState == .playing else { return }
        player.pause()
        wasPaused = true
    }

    private func resumePlaybackIfNeeded(with player: Player?) {
        guard let player, wasPaused else { return }
        player.play()
        wasPaused = false
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
