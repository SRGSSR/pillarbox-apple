//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

// MARK: Public CoreProperties shortcut

public extension Player {
    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    var presentationSize: CGSize? {
        properties.presentationSize
    }

    /// The duration of a chunk for the currently played item.
    var chunkDuration: CMTime {
        properties.chunkDuration
    }

    /// The current media type.
    var mediaType: MediaType {
        properties.mediaType
    }

    /// The current playback state.
    var playbackState: PlaybackState {
        properties.playbackState
    }

    /// The player rate.
    var rate: Float {
        properties.rate
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        properties.isExternalPlaybackActive
    }

    /// Represent the chronological sequence of events contained in the item log.
    var logs: PlayerItemLogs? {
        properties.logs
    }
}

extension Player {
    var streamType: StreamType {
        properties.streamType
    }

    var duration: CMTime {
        properties.duration
    }

    var seekableTimeRange: CMTimeRange {
        properties.seekableTimeRange
    }
}
