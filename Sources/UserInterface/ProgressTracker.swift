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
    @Published public var isInteracting = false {
        willSet {
            guard seekBehavior == .deferred, !newValue, let progress else { return }
            seek(toProgress: progress)
        }
    }
    @Published public var progress: Float? {
        willSet {
            guard seekBehavior == .immediate, let newValue else { return }
            seek(toProgress: newValue)
        }
    }

    private let seekBehavior: SeekBehavior

    /// Range for progress values.
    public var range: ClosedRange<Float> {
        progress != nil ? 0...1 : 0...0
    }

    /// Create a tracker updating its progress at the specified interval.
    /// - Parameter interval: The interval at which progress must be updated.
    public init(interval: CMTime, seekBehavior: SeekBehavior = .immediate) {
        self.seekBehavior = seekBehavior
        Publishers.CombineLatest($player, $isInteracting)
            .map { player, isInteracting -> AnyPublisher<Float?, Never> in
                guard let player else {
                    return Just(nil).eraseToAnyPublisher()
                }
                guard !isInteracting else {
                    return Empty(completeImmediately: false).eraseToAnyPublisher()
                }
                return Publishers.CombineLatest3(
                    player.periodicTimePublisher(forInterval: interval, queue: .global(qos: .default)),
                    player.$timeRange,
                    player.$isSeeking
                )
                .compactMap { time, timeRange, isSeeking in
                    guard !isSeeking else { return nil }
                    return Self.progress(for: time, in: timeRange)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$progress)
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

    private func seek(toProgress progress: Float) {
        guard let player, let time = Self.time(forProgress: progress, in: player.timeRange) else { return }
        player.seek(to: time)
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
