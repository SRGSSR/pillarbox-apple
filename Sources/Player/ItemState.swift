//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension Player {
    enum ItemState: Equatable {
        case unknown
        case readyToPlay
        case ended
        case failed(error: Error)

        static func == (lhs: Player.ItemState, rhs: Player.ItemState) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown):
                return true
            case (.readyToPlay, .readyToPlay):
                return true
            case (.ended, .ended):
                return true
            case let (.failed(error: lhsError), .failed(error: rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }

        static func publisher(for item: AVPlayerItem) -> AnyPublisher<ItemState, Never> {
            return item.publisher(for: \.status)
                .map { ItemState(from: $0) }
                .eraseToAnyPublisher()
        }

        init(from status: AVPlayerItem.Status) {
            switch status {
            case .readyToPlay:
                self = .readyToPlay
            default:
                self = .unknown
            }
        }
    }
}
