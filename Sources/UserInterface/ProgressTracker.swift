//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Player
import SwiftUI

/// Tracks playback progress. Progress trackers can be locally instantiated in a SwiftUI view hierarchy to trigger
/// view updates at a specific pace, avoiding unnecessary refreshes in other parts of the view hierarchy that do
/// not need to be periodically refreshed.
@MainActor
public final class ProgressTracker: ObservableObject {
    /// The player to attach. Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// Must be set to `true` during interactions updating the progress (e.g. while holding a slider knob controlling
    /// the progress).
    @Published public var isInteracting: Bool = false

    @Published private var _progress: Float? {
        willSet {
            guard let player, let _progress, let time = Self.time(forProgress: _progress, in: player.timeRange) else {
                return
            }
            player.seek(to: time)
        }
    }

    /// The current playback progress.
    public var progress: Float {
        get {
            _progress ?? 0
        }
        set {
            _progress = newValue
        }
    }

    /// Range for progress values.
    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

    /// Create a tracker updating its progress at the specified interval.
    /// - Parameter interval: The interval at which progress must be updated.
    public init(interval: CMTime) {
        $player
            .map { [$isInteracting] player -> AnyPublisher<Float?, Never> in
                guard let player else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return Publishers.CombineLatest3(
                    Self.progressPublisher(for: player, interval: interval),
                    $isInteracting,
                    player.$isSeeking
                )
                .filter { !$0.1 && !$0.2 }
                .map(\.0)
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$_progress)
    }

    private static func progressPublisher(for player: Player, interval: CMTime) -> AnyPublisher<Float?, Never> {
        Publishers.CombineLatest(
            player.periodicTimePublisher(forInterval: interval, queue: .global(qos: .default)),
            player.$timeRange
        )
        .map { time, timeRange in
            progress(for: time, in: timeRange)
        }
        .eraseToAnyPublisher()
    }

    private static func progress(for time: CMTime, in timeRange: CMTimeRange) -> Float? {
        guard time.isNumeric && timeRange.isValid && !timeRange.isEmpty else { return nil }
        let elapsedTime = (time - timeRange.start).seconds
        let duration = timeRange.duration.seconds
        return Float(elapsedTime / duration).clamped(to: 0...1)
    }

    private static func time(forProgress progress: Float, in timeRange: CMTimeRange) -> CMTime? {
        guard timeRange.isValid && !timeRange.isEmpty else { return nil }
        let multiplier = Float64(progress.clamped(to: 0...1))
        return timeRange.start + CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier)
    }
}

public extension View {
    /// Bind a progress tracker to a player.
    /// - Parameters:
    ///   - progressTracker: The progress tracker to bind.
    ///   - player: The player to observe.
    @MainActor
    func bind(_ progressTracker: ProgressTracker, to player: Player) -> some View {
        onAppear {
            progressTracker.player = player
        }
        .onChange(of: player) { newValue in
            progressTracker.player = newValue
        }
    }
}
