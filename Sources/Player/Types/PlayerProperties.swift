//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public struct PlayerProperties: Equatable {
    static var empty: Self {
        .init(itemProperties: .empty, mediaSelectionProperties: .empty, timeProperties: .empty, playbackProperties: .empty)
    }

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties
    let playbackProperties: PlaybackProperties

    public var rate: Float {
        playbackProperties.rate
    }

    public var isSeeking: Bool {
        playbackProperties.isSeeking
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
        itemProperties.isBuffering
    }

    public var chunkDuration: CMTime {
        itemProperties.chunkDuration
    }

    public var presentationSize: CGSize? {
        itemProperties.presentationSize
    }
}
