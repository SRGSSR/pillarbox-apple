//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

public struct PlayerProperties: Equatable {
    static var empty: Self {
        .init(itemProperties: .empty, rate: 0, isSeeking: false, isExternalPlaybackActive: false, isMuted: false)
    }

    let itemProperties: PlayerItemProperties

    public let rate: Float
    public let isSeeking: Bool
    public let isExternalPlaybackActive: Bool
    public let isMuted: Bool

    public var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }

    public var isBuffering: Bool {
        itemProperties.isBuffering
    }

    public var chunkDuration: CMTime {
        itemProperties.chunkDuration
    }

    public var presentationSize: CGSize? {
        itemProperties.presentationSize
    }
}
