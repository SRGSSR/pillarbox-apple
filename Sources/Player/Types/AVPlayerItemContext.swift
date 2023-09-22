//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

struct AVPlayerItemContext: Equatable {
    static var empty: Self {
        empty(state: .unknown, isPlaybackLikelyToKeepUp: true)
    }

    let state: ItemState
    let isPlaybackLikelyToKeepUp: Bool

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?
    let mediaSelectionContext: MediaSelectionContext

    var isBuffering: Bool {
        switch state {
        case .failed:
            return false
        default:
            return !isPlaybackLikelyToKeepUp
        }
    }

    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }

    static func empty(state: ItemState, isPlaybackLikelyToKeepUp: Bool) -> Self {
        .init(
            state: state,
            isPlaybackLikelyToKeepUp: isPlaybackLikelyToKeepUp,
            duration: .invalid,
            minimumTimeOffsetFromLive: .invalid,
            presentationSize: nil,
            mediaSelectionContext: .empty
        )
    }
}
