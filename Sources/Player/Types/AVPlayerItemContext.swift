//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

struct AVPlayerItemContext: Equatable {
    static var empty: Self {
        empty(state: .unknown)
    }

    let state: ItemState
    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime
    let isPlaybackLikelyToKeepUp: Bool
    let presentationSize: CGSize?
    let mediaSelectionContext: MediaSelectionContext

    var chunkDuration: CMTime {
        // The minimum offset represents 3 chunks
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }

    var isBuffering: Bool {
        switch state {
        case .failed:
            return false
        default:
            return !isPlaybackLikelyToKeepUp
        }
    }

    static func empty(state: ItemState) -> Self {
        .init(
            state: state,
            duration: .invalid,
            minimumTimeOffsetFromLive: .invalid,
            isPlaybackLikelyToKeepUp: true,
            presentationSize: nil,
            mediaSelectionContext: .empty
        )
    }
}
