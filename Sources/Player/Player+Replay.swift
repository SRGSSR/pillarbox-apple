//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Player {
    /// Checks whether the player has finished playing and its content can be played again.
    ///
    /// - Returns: `true` if possible.
    ///
    /// If all content has been played the player will start again from the first item. In case of a failure
    /// playback will start again from the failed item.
    func canReplay() -> Bool {
        guard !storedItems.isEmpty else { return false }
        return queuePlayer.items().isEmpty || error != nil
    }

    /// Replays the content, resuming playback automatically.
    func replay() {
        guard canReplay() else { return }
        play()
        try? setCurrentIndex(currentIndex ?? 0)
    }
}
