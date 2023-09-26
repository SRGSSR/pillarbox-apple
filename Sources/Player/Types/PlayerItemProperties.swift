//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

public struct PlayerItemProperties: Equatable {
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
    public let isPlaybackLikelyToKeepUp: Bool

    public let duration: CMTime
    public let minimumTimeOffsetFromLive: CMTime

    public let presentationSize: CGSize?
    let mediaSelectionContext: MediaSelectionContext

    public var isBuffering: Bool {
        !isPlaybackLikelyToKeepUp
    }

    public var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }
}
