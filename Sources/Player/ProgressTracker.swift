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

        // Intentionally kept private. Used for display only, seeks must rely on most recent player values.
        private let timeRange: CMTimeRange

        init(time: CMTime, timeRange: CMTimeRange) {
            self.time = time
            self.timeRange = timeRange
        }

        static var invalid: Self {
            .init(time: .invalid, timeRange: .invalid)
        }

        var isValid: Bool {
            time.isValid && timeRange.isValidAndNotEmpty
        }

        var progress: Float? {
            guard isValid else { return nil }
            let elapsedTime = (time - timeRange.start).seconds
            let duration = timeRange.duration.seconds
            return Float(elapsedTime / duration).clamped(to: 0...1)
        }

        func withProgress(_ progress: Float) -> Self {
            guard timeRange.isValidAndNotEmpty else { return .invalid }
            let multiplier = Float64(progress.clamped(to: 0...1))
            let time = timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier)
            return .init(time: time, timeRange: timeRange)
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
            state.progress ?? 0
        }
        set {
            state = state.withProgress(newValue)
        }
    }

    /// The time corresponding to the current progress. Might be different from the player current time when
    /// interaction takes place.
    public var time: CMTime? {
        state.time
    }

    /// Range for progress values.
    public var range: ClosedRange<Float> {
        state.isValid ? 0...1 : 0...0
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
                return Publishers.CombineLatest(
                    Self.currentTimePublisher(for: player, interval: interval, isInteracting: $isInteracting),
                    player.queuePlayer.currentItemTimeRangePublisher()
                )
                .compactMap { time, timeRange in
                    State(time: time, timeRange: timeRange)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
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

    private func seek(to state: State) {
        // Always calculate the target time based on the progress and most recent player range information
        guard let progress = state.progress, let player else { return }
        let timeRange = player.timeRange
        guard timeRange.isValidAndNotEmpty else { return }
        let time = timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: Float64(progress))
        player.seek(to: time, smooth: true)
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
