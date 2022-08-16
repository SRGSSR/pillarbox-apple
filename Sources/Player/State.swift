//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension Player {
    enum State {
        case idle
        case playing
        case paused
        case ended
        case failed(error: Error)

        init(from playerState: PlayerState) {
            switch playerState.itemState {
            case .readyToPlay:
                self = (playerState.rate == 0) ? .paused : .playing
            case let .failed(error: error):
                self = .failed(error: error)
            case .ended:
                self = .ended
            case .unknown:
                self = .idle
            }
        }
    }

    struct PlayerState {
        let itemState: ItemState
        let rate: Float
    }
}
