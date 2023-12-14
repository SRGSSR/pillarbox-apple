//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct CoreProperties: Equatable {
    static var empty: Self {
        .init(itemProperties: .empty, mediaSelectionProperties: .empty, playbackProperties: .empty)
    }

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let playbackProperties: PlaybackProperties
}

// MARK: ItemProperties

extension CoreProperties {
    var state: ItemState {
        itemProperties.state
    }

    var duration: CMTime {
        itemProperties.duration
    }

    var minimumTimeOffsetFromLive: CMTime {
        itemProperties.minimumTimeOffsetFromLive
    }

    var presentationSize: CGSize? {
        itemProperties.presentationSize
    }
}

extension CoreProperties {
    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }

    var mediaType: MediaType {
        guard let presentationSize else { return .unknown }
        if presentationSize == .zero {
            return .audio
        }
        else if presentationSize.width / presentationSize.height >= 2 {
            return .monoscopicVideo
        }
        else {
            return .video
        }
    }

    var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }
}

// MARK: PlaybackProperties

extension CoreProperties {
    var rate: Float {
        playbackProperties.rate
    }

    var isExternalPlaybackActive: Bool {
        playbackProperties.isExternalPlaybackActive
    }

    var isMuted: Bool {
        playbackProperties.isMuted
    }
}
