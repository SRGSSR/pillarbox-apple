//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension Player {
    /// Resume playback.
    func play() {
        queuePlayer.play()
    }

    /// Pause playback.
    func pause() {
        queuePlayer.pause()
    }

    /// Toggle playback between play and pause.
    func togglePlayPause() {
        if queuePlayer.rate != 0 {
            queuePlayer.pause()
        }
        else {
            queuePlayer.play()
        }
    }
}
