//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Player
import SwiftUI

/// Tracks playback progress. SwiftUI apps should locally track progress to avoid performing unnecessary view updates.
@MainActor
public final class ProgressTracker: ObservableObject {
    /// The player to attach. Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?
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
            .map { Self.progressPublisher(for: $0, interval: interval) }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$_progress)
    }

    private static func progressPublisher(for player: Player?, interval: CMTime) -> AnyPublisher<Float?, Never> {
        guard let player else {
            return Just(Optional<Float>.none).eraseToAnyPublisher()
        }
        return Publishers.CombineLatest(
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
    /// Bind a tracker to a player.
    /// - Parameters:
    ///   - tracker: The tracker to bind.
    ///   - player: The player to observe.
    @MainActor
    func bind(_ tracker: ProgressTracker, to player: Player) -> some View {
        onAppear {
            tracker.player = player
        }
        .onChange(of: player) { newValue in
            tracker.player = newValue
        }
    }
}
