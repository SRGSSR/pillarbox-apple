//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Player {
    /// Indicates whether the current content can be replayed.
    ///
    /// The behavior depends on the value of ``Player/actionAtItemEnd``:
    ///
    /// - If set to `.advance`, replay becomes available once all items have been played.
    ///   Playback restarts from the first item.
    /// - If set to `.pause` or `.none`, replay becomes available at the end of each item.
    ///   Playback restarts from the current item.
    func canReplay() -> Bool {
        guard !storedItems.isEmpty else { return false }
        switch actionAtItemEnd {
        case .advance:
            return queuePlayer.items().isEmpty || error != nil
        default:
            return playbackState == .ended
        }
    }

    /// Replays the content, resuming playback automatically.
    func replay() {
        guard canReplay() else { return }
        switch actionAtItemEnd {
        case .advance:
            play()
            replaceCurrentItemWithItem(currentItem ?? items.first)
        default:
            skipToDefault { [weak self] _ in
                self?.play()
            }
        }
    }
}
