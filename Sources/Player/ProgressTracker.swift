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
    private struct State {
        let time: CMTime
        let timeRange: CMTimeRange

        static var invalid: Self {
            .init(time: .invalid, timeRange: .invalid)
        }

        var isValid: Bool {
            time.isValid && Self.isValid(timeRange)
        }

        static func isValid(_ timeRange: CMTimeRange) -> Bool {
            timeRange.isValid && !timeRange.isEmpty
        }
    }

    /// The player to attach. Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// Must be set to `true` to report user interaction to the progress tracker.
    @Published public var isInteracting = false {
        // Not called when updated via $state. Seeks are therefore only triggered with external changes.
        willSet {
            guard seekBehavior == .deferred, !newValue else { return }
            seek(to: state)
        }
    }

    @Published private var state: State = .invalid {
        // Not called when updated via $state. Seeks are therefore only triggered with external changes.
        willSet {
            guard seekBehavior == .immediate else { return }
            seek(to: newValue)
        }
    }

    private let seekBehavior: SeekBehavior

    /// The current progress. Might be different from the player progress when interaction takes place.
    public var progress: Float {
        get {
            Self.progress(for: state)
        }
        set {
            let timeRange = state.timeRange
            let time = Self.time(forProgress: newValue, in: timeRange)
            state = State(time: time, timeRange: timeRange)
        }
    }

    /// The time corresponding to the current progress. Might be different from the player current time when
    /// interaction takes place.
    public var time: CMTime? {
        state.time
    }

    /// Range for progress values.
    public var range: ClosedRange<Float> {
        let timeRange = state.timeRange
        return (timeRange.isValid && !timeRange.isEmpty) ? 0...1 : 0...0
    }

    /// Create a tracker updating its progress at the specified interval.
    /// - Parameter interval: The interval at which progress must be updated.
    public init(interval: CMTime, seekBehavior: SeekBehavior = .immediate) {
        self.seekBehavior = seekBehavior
        $player
            .map { [$isInteracting] player -> AnyPublisher<State, Never> in
                guard let player else {
                    return Just(.invalid).eraseToAnyPublisher()
                }
                return Publishers.CombineLatest3(
                    player.queuePlayer.smoothCurrentTimePublisher(interval: interval, queue: .main),
                    player.queuePlayer.currentItemTimeRangePublisher(),
                    $isInteracting
                )
                .compactMap { time, timeRange, isInteracting in
                    guard !isInteracting else { return nil }
                    return State(time: time, timeRange: timeRange)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func progress(for state: State) -> Float {
        guard state.isValid else { return 0 }
        let elapsedTime = (state.time - state.timeRange.start).seconds
        let duration = state.timeRange.duration.seconds
        return Float(elapsedTime / duration).clamped(to: 0...1)
    }

    private static func time(forProgress progress: Float, in timeRange: CMTimeRange) -> CMTime {
        guard State.isValid(timeRange) else { return .invalid }
        let multiplier = Float64(progress.clamped(to: 0...1))
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier)
    }

    private func seek(to state: State) {
        guard let player, state.isValid else { return }
        player.seek(to: state.time, smooth: true)
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
