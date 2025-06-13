//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Player {
    /// A Boolean value whether the player should play content when possible.
    var shouldPlay: Bool {
        get {
            queuePlayer.rate != 0
        }
        set {
            if newValue {
                queuePlayer.rate = queuePlayer.defaultRate
            }
            else {
                queuePlayer.rate = 0
            }
        }
    }

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
