//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct PlaybackProperties: Equatable {
    static var empty: Self {
        .init(rate: 0, isSeeking: false, isExternalPlaybackActive: false, isMuted: false)
    }

    let rate: Float
    let isSeeking: Bool         // TODO: Must be moved outside since changing fast
    let isExternalPlaybackActive: Bool
    let isMuted: Bool
}
