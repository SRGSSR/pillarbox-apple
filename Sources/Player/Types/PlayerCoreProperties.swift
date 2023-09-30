//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct PlayerCoreProperties: Equatable {
    static var empty: Self {
        .init(itemProperties: .empty, mediaSelectionProperties: .empty, playbackProperties: .empty)
    }

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let playbackProperties: PlaybackProperties

    var rate: Float {
        playbackProperties.rate
    }

    var isExternalPlaybackActive: Bool {
        playbackProperties.isExternalPlaybackActive
    }

    var isMuted: Bool {
        playbackProperties.isMuted
    }

    var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }

    var chunkDuration: CMTime {
        itemProperties.chunkDuration
    }

    var presentationSize: CGSize? {
        itemProperties.presentationSize
    }
}
