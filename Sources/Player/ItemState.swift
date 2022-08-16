//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension Player {
    enum ItemState {
        case unknown
        case readyToPlay
        case ended
        case failed

        static func publisher(for item: AVPlayerItem) -> AnyPublisher<ItemState, Never> {
            return item.publisher(for: \.status)
                .map { ItemState(from: $0) }
                .eraseToAnyPublisher()
        }

        init(from status: AVPlayerItem.Status) {
            switch status {
            case .readyToPlay:
                self = .readyToPlay
            case .failed:
                self = .failed
            default:
                self = .unknown
            }
        }
    }
}
