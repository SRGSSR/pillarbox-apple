//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

// TODO: Transform into instance methods
extension AVPlayer {
    static func itemDurationPublisher(for player: AVPlayer) -> AnyPublisher<CMTime, Never> {
        Just(.zero).eraseToAnyPublisher()
    }

    static func timeRangePublisher(for player: AVPlayer) -> AnyPublisher<CMTimeRange, Never> {
        Just(.zero).eraseToAnyPublisher()
    }

    static func currentTimePublisher(for player: AVPlayer, interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.Merge(
            ItemState.publisher(for: player)
                .filter { $0 == .readyToPlay }
                .map { _ in .zero },
            Publishers.PeriodicTimePublisher(for: player, interval: interval, queue: queue)
        )
        .eraseToAnyPublisher()
    }

    static func seekTargetTimePublisher(for player: AVPlayer) -> AnyPublisher<CMTime?, Never> {
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
