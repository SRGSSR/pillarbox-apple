//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension Player {
    /// Checks whether the player has finished playing and its content can be played again from the start.
    ///
    /// - Returns: `true` if possible.
    func canReplay() -> Bool {
        guard !storedItems.isEmpty else { return false }
        return currentItem.smoothPlayerItem(in: storedItems) == nil
    }

    /// Replays the content from the start, resuming playback automatically.
    func replay() {
        guard canReplay() else { return }
        play()
        try? setCurrentIndex(0)
    }
}
