//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A type describing player properties.
public struct PlayerProperties: Equatable {
    static var empty: Self {
        .init(
            itemProperties: .empty,
            mediaSelectionProperties: .empty,
            timeProperties: .empty,
            playbackProperties: .empty,
            isEmpty: true,
            seekTime: nil
        )
    }

    let itemProperties: ItemProperties
    let mediaSelectionProperties: MediaSelectionProperties
    let timeProperties: TimeProperties
    let playbackProperties: PlaybackProperties
    let isEmpty: Bool

    /// The time at which the player is currently seeking, if any.
    public let seekTime: CMTime?

    /// A Boolean describing whether the player is currently seeking to another position.
    public var isSeeking: Bool {
        seekTime != nil
    }

    /// The player rate.
    public var rate: Float {
        playbackProperties.rate
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    public var isExternalPlaybackActive: Bool {
        playbackProperties.isExternalPlaybackActive
    }

    /// A Boolean describing whether the player is currently muted.
    public var isMuted: Bool {
        playbackProperties.isMuted
    }

    /// The player playback state.
    public var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }

    /// A Boolean describing whether the player is currently buffering.
    public var isBuffering: Bool {
        !isEmpty && !timeProperties.isPlaybackLikelyToKeepUp
    }

    /// The buffer position.
    ///
    /// Returns a value between 0 and 1 indicating up to where content has been loaded and is available for
    /// playback.
    public var buffer: Float {
        timeProperties.buffer
    }

    /// A Boolean describing whether the player is currently busy (buffering or seeking).
    public var isBusy: Bool {
        isBuffering || isSeeking
    }

    /// The duration of a chunk for the currently played item.
    ///
    /// Might be `.invalid` when no content is being played or when unknown.
    public var chunkDuration: CMTime {
        itemProperties.chunkDuration
    }

    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    public var presentationSize: CGSize? {
        itemProperties.presentationSize
    }

    /// The current media type.
    public var mediaType: MediaType {
        guard let presentationSize else { return .unknown }
        return presentationSize == .zero ? .audio : .video
    }

    var coreProperties: PlayerCoreProperties {
        .init(
            itemProperties: itemProperties,
            mediaSelectionProperties: mediaSelectionProperties,
            playbackProperties: playbackProperties
        )
    }
}
