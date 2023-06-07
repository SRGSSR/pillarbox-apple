//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension Player {
    /// Check whether the player has finished playing its content and can be restarted.
    /// - Returns: `true` if possible.
    func canRestart() -> Bool {
        guard !storedItems.isEmpty else { return false }
        return currentItem.smoothPlayerItem(in: storedItems) == nil
    }

    /// Restart playback if possible.
    func restart() {
        guard canRestart() else { return }
        try? setCurrentIndex(0)
    }
}
