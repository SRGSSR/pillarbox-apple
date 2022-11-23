//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Player
import SwiftUI

@MainActor
public final class ProgressTracker: ObservableObject {
    @Published public var player: Player?
    @Published private var _progress: Float?

    public var progress: Float {
        get {
            _progress ?? 0
        }
        set {
            _progress = newValue
        }
    }

    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

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
}

public extension View {
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
