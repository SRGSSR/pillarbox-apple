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
}

// MARK: ItemProperties
extension PlayerCoreProperties {
    var state: ItemState {
        itemProperties.state
    }

    /// The stream duration.
    var duration: CMTime {
        itemProperties.duration
    }

    var minimumTimeOffsetFromLive: CMTime {
        itemProperties.minimumTimeOffsetFromLive
    }

    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    var presentationSize: CGSize? {
        itemProperties.presentationSize
    }

    /// The duration of a chunk for the currently played item.
    ///
    /// Might be `.invalid` when no content is being played or when unknown.
    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }

    /// The current media type.
    public var mediaType: MediaType {
        guard let presentationSize else { return .unknown }
        return presentationSize == .zero ? .audio : .video
    }

    /// The player playback state.
    public var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }
}

// MARK: PlaybackProperties
extension PlayerCoreProperties {
    /// The player rate.
    var rate: Float {
        playbackProperties.rate
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        playbackProperties.isExternalPlaybackActive
    }

    /// A Boolean describing whether the player is currently muted.
    var isMuted: Bool {
        playbackProperties.isMuted
    }
}
