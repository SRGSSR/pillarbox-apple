//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct PlayerItemProperties: Equatable {
    static var empty: Self {
        .init(
            state: .unknown,
            isPlaybackLikelyToKeepUp: true,
            duration: .invalid,
            minimumTimeOffsetFromLive: .invalid,
            presentationSize: nil,
            mediaSelectionProperties: .empty,
            timeProperties: .empty
        )
    }

    let state: ItemState
    let isPlaybackLikelyToKeepUp: Bool

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?

    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties

    var isBuffering: Bool {
        !isPlaybackLikelyToKeepUp
    }

    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }
}
