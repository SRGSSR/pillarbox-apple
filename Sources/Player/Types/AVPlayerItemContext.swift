//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

struct AVPlayerItemContext {
    static var empty: Self {
        .init(state: .unknown, duration: .invalid, isBuffering: false)
    }

    let state: ItemState
    let duration: CMTime
    let isBuffering: Bool
}
