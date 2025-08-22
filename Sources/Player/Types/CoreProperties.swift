//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct CoreProperties: Equatable {
    static let empty = Self(itemProperties: .empty, mediaSelectionProperties: .empty, playbackProperties: .empty, mediaSelectionCriteria: [:])

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let playbackProperties: PlaybackProperties
    let mediaSelectionCriteria: [AVMediaCharacteristic: AVPlayerMediaSelectionCriteria?]
}

// MARK: ItemProperties

extension CoreProperties {
    var itemStatus: ItemStatus {
        itemProperties.status
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
    func time() -> CMTime {
        itemProperties.time()
    }

    func date() -> Date? {
        itemProperties.date()
    }

    func metrics() -> Metrics? {
        itemProperties.metrics()
    }
}

extension CoreProperties {
    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }

    var mediaType: MediaType {
        guard let presentationSize else { return .unknown }
        return presentationSize == .zero ? .audio : .video
    }

    var playbackState: PlaybackState {
        .init(itemStatus: itemStatus, rate: rate)
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
