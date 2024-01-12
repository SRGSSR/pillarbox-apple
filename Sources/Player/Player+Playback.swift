//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Player {
    /// Resumes playback.
    func play() {
        shouldPlay = true
    }

    /// Pauses playback.
    func pause() {
        shouldPlay = false
    }

    /// Toggles playback between play and pause.
    func togglePlayPause() {
        shouldPlay.toggle()
    }
}
