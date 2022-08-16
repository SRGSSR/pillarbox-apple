//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Player {
    public enum State {
        case idle
        case playing
        case paused
        case ended
        case failed(error: Error)
    }
}
