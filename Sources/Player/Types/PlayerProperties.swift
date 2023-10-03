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
            timeProperties: .empty,
            playbackProperties: .empty,
            mediaSelectionProperties: .empty,
            isEmpty: true,
            seekTime: nil
        )
    }

    private let itemProperties: ItemProperties
    private let timeProperties: TimeProperties
    private let playbackProperties: PlaybackProperties

    let mediaSelectionProperties: MediaSelectionProperties
    let isEmpty: Bool

    /// The time at which the player is currently seeking, if any.
    public let seekTime: CMTime?

    /// A Boolean describing whether the player is currently seeking to another position.
    public var isSeeking: Bool {
        seekTime != nil
    }

    /// The player playback state.
    public var playbackState: PlaybackState {
        .init(itemState: itemProperties.state, rate: rate)
    }

    /// A Boolean describing whether the player is currently buffering.
    public var isBuffering: Bool {
        !isEmpty && !timeProperties.isPlaybackLikelyToKeepUp
    }

    /// A Boolean describing whether the player is currently busy (buffering or seeking).
    public var isBusy: Bool {
        isBuffering || isSeeking
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

    init(
        itemProperties: ItemProperties,
        timeProperties: TimeProperties,
        playbackProperties: PlaybackProperties,
        mediaSelectionProperties: MediaSelectionProperties,
        isEmpty: Bool,
        seekTime: CMTime?
    ) {
        self.itemProperties = itemProperties
        self.timeProperties = timeProperties
        self.playbackProperties = playbackProperties
        self.mediaSelectionProperties = mediaSelectionProperties
        self.isEmpty = isEmpty
        self.seekTime = seekTime
    }
}

// MARK: ItemProperties
extension PlayerProperties {
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
    public var presentationSize: CGSize? {
        itemProperties.presentationSize
    }

    /// The duration of a chunk for the currently played item.
    ///
    /// Might be `.invalid` when no content is being played or when unknown.
    public var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }
}

// MARK: TimeProperties
extension PlayerProperties {
    var loadedTimeRanges: [NSValue] {
        timeProperties.loadedTimeRanges
    }

    var seekableTimeRanges: [NSValue] {
        timeProperties.seekableTimeRanges
    }

    var isPlaybackLikelyToKeepUp: Bool {
        timeProperties.isPlaybackLikelyToKeepUp
    }

    /// The time range within which it is possible to seek.
    public var seekableTimeRange: CMTimeRange {
        timeProperties.seekableTimeRange
    }

    var loadedTimeRange: CMTimeRange {
        timeProperties.loadedTimeRange
    }

    /// The buffer position.
    ///
    /// Returns a value between 0 and 1 indicating up to where content has been loaded and is available for
    /// playback.
    public var buffer: Float {
        timeProperties.buffer
    }
}

// MARK: PlaybackProperties
public extension PlayerProperties {
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
