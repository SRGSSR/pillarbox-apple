//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Player {
    /// Resumes playback.
    func play() {
        queuePlayer.play()
    }

    /// Pauses playback.
    func pause() {
        queuePlayer.pause()
    }

    /// Toggles playback between play and pause.
    func togglePlayPause() {
        if isPlaybackActive {
            queuePlayer.pause()
        }
        else {
            queuePlayer.play()
        }
    }
}
