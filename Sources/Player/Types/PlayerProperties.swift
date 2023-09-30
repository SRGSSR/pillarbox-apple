//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public struct PlayerProperties: Equatable {
    static var empty: Self {
        .init(
            itemProperties: .empty,
            mediaSelectionProperties: .empty,
            timeProperties: .empty,
            playbackProperties: .empty,
            isSeeking: false
        )
    }

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties
    let playbackProperties: PlaybackProperties

    public let isSeeking: Bool

    public var rate: Float {
        playbackProperties.rate
    }

    public var isExternalPlaybackActive: Bool {
        playbackProperties.isExternalPlaybackActive
    }

    public var isMuted: Bool {
        playbackProperties.isMuted
    }

    public var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }

    public var isBuffering: Bool {
        timeProperties.isBuffering
    }

    public var buffer: Float {
        timeProperties.buffer
    }

    public var isBusy: Bool {
        isBuffering || isSeeking
    }

    public var chunkDuration: CMTime {
        itemProperties.chunkDuration
    }

    public var presentationSize: CGSize? {
        itemProperties.presentationSize
    }

    var coreProperties: PlayerCoreProperties {
        .init(
            itemProperties: itemProperties,
            mediaSelectionProperties: mediaSelectionProperties,
            playbackProperties: playbackProperties
        )
    }
}
