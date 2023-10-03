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
            timeProperties: .empty,
            coreProperties: .empty,
            isEmpty: true,
            seekTime: nil
        )
    }

    private let timeProperties: TimeProperties
    let coreProperties: PlayerCoreProperties

    let isEmpty: Bool

    /// The time at which the player is currently seeking, if any.
    public let seekTime: CMTime?

    /// A Boolean describing whether the player is currently seeking to another position.
    public var isSeeking: Bool {
        seekTime != nil
    }

    /// The player playback state.
    public var playbackState: PlaybackState {
        coreProperties.playbackState
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
        coreProperties.mediaType
    }

    init(
        timeProperties: TimeProperties,
        coreProperties: PlayerCoreProperties,
        isEmpty: Bool,
        seekTime: CMTime?
    ) {
        self.timeProperties = timeProperties
        self.coreProperties = coreProperties
        self.isEmpty = isEmpty
        self.seekTime = seekTime
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

// MARK: ItemProperties
extension PlayerProperties {
    var state: ItemState {
        coreProperties.state
    }

    /// The stream duration.
    public var duration: CMTime {
        coreProperties.duration
    }

    var minimumTimeOffsetFromLive: CMTime {
        coreProperties.minimumTimeOffsetFromLive
    }

    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    public var presentationSize: CGSize? {
        coreProperties.presentationSize
    }

    /// The duration of a chunk for the currently played item.
    ///
    /// Might be `.invalid` when no content is being played or when unknown.
    public var chunkDuration: CMTime {
        coreProperties.chunkDuration
    }
}

// MARK: PlaybackProperties
public extension PlayerProperties {
    /// The player rate.
    var rate: Float {
        coreProperties.rate
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        coreProperties.isExternalPlaybackActive
    }

    /// A Boolean describing whether the player is currently muted.
    var isMuted: Bool {
        coreProperties.isMuted
    }
}
