//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

/// Playback properties.
public struct PlaybackProperties {
    /// Pulse.
    public let pulse: Pulse

    /// Time targeted by a pending seek, if any.
    public let targetTime: CMTime?

    /// The stream type.
    public var streamType: StreamType {
        let timeRange = pulse.timeRange
        guard timeRange.isValid else { return .unknown }
        return .onDemand
    }

    /// A value in 0...1 describing the playback progress targeted by a pending seek, if any.
    public var targetProgress: Float? {
        guard let targetTime else { return nil }
        return pulse.progress(for: targetTime)
    }

    static var empty: Self {
        PlaybackProperties(pulse: .empty, targetTime: nil)
    }

    static func publisher(for player: AVPlayer) -> AnyPublisher<PlaybackProperties, Never> {
        Publishers.CombineLatest(
            Pulse.publisher(for: player, queue: DispatchQueue(label: "ch.srgssr.pillarbox.player")),
            seekTargetPublisher(for: player)
        )
        .map { PlaybackProperties(pulse: $0, targetTime: $1) }
        .eraseToAnyPublisher()
    }

    private static func seekTargetPublisher(for player: AVPlayer) -> AnyPublisher<CMTime?, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: .willSeek, object: player)
                .map { $0.userInfo?[DequeuePlayer.SeekInfoKey.targetTime] as? CMTime },
            NotificationCenter.default.weakPublisher(for: .didSeek, object: player)
                .map { _ in nil }
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }
}
