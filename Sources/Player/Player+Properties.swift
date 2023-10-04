//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension Player {
    /// The current playback state.
    var playbackState: PlaybackState {
        properties.playbackState
    }

    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    var presentationSize: CGSize? {
        properties.presentationSize
    }

    /// The current media type.
    var mediaType: MediaType {
        properties.mediaType
    }

    /// The duration of a chunk for the currently played item.
    var chunkDuration: CMTime {
        properties.chunkDuration
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        properties.isExternalPlaybackActive
    }

    /// The available time range.
    ///
    /// `.invalid` when unknown.
    var timeRange: CMTimeRange {
        // TODO: Try to remove it! Used by analytics.
        properties.seekableTimeRange
    }
}

extension Player {
    var streamType: StreamType {
        properties.streamType
    }

    var duration: CMTime {
        properties.duration
    }
}
