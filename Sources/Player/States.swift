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
    }

    enum ItemState {
        case unknown
        case readyToPlay
        case ended
        case failed(error: Error)
    }
}
