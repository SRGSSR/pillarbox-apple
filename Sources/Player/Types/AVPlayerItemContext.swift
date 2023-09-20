//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

struct AVPlayerItemContext {
    static var empty: Self {
        .init(state: .unknown, duration: .invalid, minimumTimeOffsetFromLive: .invalid, isBuffering: false)
    }

    let state: ItemState
    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime
    let isBuffering: Bool

    var chunkDuration: CMTime {
        // The minimum offset represents 3 chunks
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }
}
