//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Timing<C>: Equatable where C: Clock {
    let start: C.Instant
    let duration: C.Duration

    var end: C.Instant {
        start.advanced(by: duration)
    }
}
