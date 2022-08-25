//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

enum ItemState {
    case unknown
    case readyToPlay
    case ended
    case failed(error: Error)

    private static func publisher(for item: AVPlayerItem) -> AnyPublisher<ItemState, Never> {
        Publishers.Merge(
            item.publisher(for: \.status)
                .map { status in
                    switch status {
                    case .readyToPlay:
                        return .readyToPlay
                    case .failed:
                        return .failed(error: item.error ?? PlaybackError.unknown)
                    default:
                        return .unknown
                    }
                },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                .map { _ in .ended }
        )
        .eraseToAnyPublisher()
    }

    static func publisher(for player: AVPlayer) -> AnyPublisher<ItemState, Never> {
        player.publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { publisher(for: $0) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
