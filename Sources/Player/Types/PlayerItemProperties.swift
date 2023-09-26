//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

struct PlayerItemProperties: Equatable {
    static var empty: Self {
        .init(
            state: .unknown,
            isPlaybackLikelyToKeepUp: true,
            duration: .invalid,
            minimumTimeOffsetFromLive: .invalid,
            presentationSize: nil,
            mediaSelectionContext: .empty
        )
    }

    let state: ItemState
    let isPlaybackLikelyToKeepUp: Bool

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?
    let mediaSelectionContext: MediaSelectionContext

    var isBuffering: Bool {
        !isPlaybackLikelyToKeepUp
    }

    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }
}
