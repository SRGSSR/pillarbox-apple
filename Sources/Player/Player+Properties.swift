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

    /// The duration of a chunk for the currently played item.
    var chunkDuration: CMTime {
        properties.chunkDuration
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        properties.isExternalPlaybackActive
    }
}
