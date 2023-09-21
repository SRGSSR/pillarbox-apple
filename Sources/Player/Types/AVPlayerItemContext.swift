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

    let isPlaybackLikelyToKeepUp: Bool
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

    static func empty(state: ItemState) -> Self {
        .init(
            state: state,
            isPlaybackLikelyToKeepUp: true,
            presentationSize: nil,
            mediaSelectionContext: .empty
        )
    }
}
