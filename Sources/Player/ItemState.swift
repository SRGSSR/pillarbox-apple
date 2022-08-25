//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

enum ItemState: Equatable {
    case unknown
    case readyToPlay
    case ended
    case failed(error: Error)

    private static func itemState(for item: AVPlayerItem?) -> ItemState {
        guard let item else { return .unknown }
        return itemState(for: item.status, error: item.error)
    }

    private static func itemState(for status: AVPlayerItem.Status, error: Error?) -> ItemState {
        switch status {
        case .readyToPlay:
            return .readyToPlay
        case .failed:
            return .failed(error: error ?? PlaybackError.unknown)
        default:
            return .unknown
        }
    }

    private static func publisher(for item: AVPlayerItem) -> AnyPublisher<ItemState, Never> {
        return Publishers.Merge(
            item.publisher(for: \.status)
                .map { itemState(for: $0, error: item.error) },
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
            .prepend(itemState(for: player.currentItem))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // Ignore differences between errors (different errors should never occur in practice for the same item anyway).
    static func == (lhs: ItemState, rhs: ItemState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.readyToPlay, .readyToPlay), (.ended, .ended), (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
