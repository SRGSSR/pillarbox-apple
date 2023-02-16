//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import SwiftUI

/// Tracks playback progress. Progress trackers can be locally instantiated in a SwiftUI view hierarchy to trigger
/// view updates at a specific pace, avoiding unnecessary refreshes in other parts of the view hierarchy that do
/// not need to be periodically refreshed.
public final class ProgressTracker: ObservableObject {
    /// The player to attach. Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// Must be set to `true` to report user interaction to the progress tracker.
    @Published public var isInteracting = false {
        willSet {
            guard seekBehavior == .deferred, !newValue else { return }
            seek(to: progress)
        }
    }

    @Published private var _progress: Float?

    private let seekBehavior: SeekBehavior

    /// The current progress. Might be different from the player progress when interaction takes place.
    public var progress: Float {
        get {
            (_progress ?? 0).clamped(to: range)
        }
        set {
            _progress = newValue
            guard seekBehavior == .immediate else { return }
            seek(to: newValue)
        }
    }

    /// The time corresponding to the current progress. Might be different from the player current time when
    /// interaction takes place.
    public var time: CMTime? {
        time(forProgress: progress)
    }

    /// Range for progress values.
    public var range: ClosedRange<Float> {
        timeRange != nil ? 0...1 : 0...0
    }

    private var timeRange: CMTimeRange? {
        guard let timeRange = player?.timeRange, timeRange.isValidAndNotEmpty else { return nil }
        return timeRange
    }

    /// Create a tracker updating its progress at the specified interval.
    /// - Parameter interval: The interval at which progress must be updated.
    public init(interval: CMTime, seekBehavior: SeekBehavior = .immediate) {
        self.seekBehavior = seekBehavior
        $player
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

    private func seek(to progress: Float) {
        guard let player, let time = time(forProgress: progress) else { return }
        player.seek(to: time, smooth: true)
    }

    private func time(forProgress progress: Float) -> CMTime? {
        guard let timeRange else { return nil }
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: Float64(progress))
    }
}

public extension View {
    /// Bind a progress tracker to a player.
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
