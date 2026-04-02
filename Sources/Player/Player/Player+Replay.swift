//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

private enum ReplayAction {
    case none
    case restart
    case reload
}

public extension Player {
    /// Indicates whether the current content can be replayed.
    ///
    /// The behavior depends on the value of ``Player/actionAtItemEnd``:
    ///
    /// - If set to `.advance`, replay becomes available once all items have been played. Playback restarts from the
    ///   first item.
    /// - If set to `.pause` or `.none`, replay becomes available at the end of each item. Playback restarts from the
    ///   current item.
    func canReplay() -> Bool {
        replayAction() != .none
    }

    /// Replays the content, resuming playback automatically.
    func replay() {
        switch replayAction() {
        case .none:
            break
        case .restart:
            skipToDefault { [weak self] _ in
                self?.play()
            }
        case .reload:
            play()
            replaceCurrentItemWithItem(currentItem ?? items.first)
        }
    }

    private func replayAction() -> ReplayAction {
        guard !storedItems.isEmpty else { return .none }
        if queuePlayer.items().isEmpty || error != nil {
            return .reload
        }
        else if playbackState == .ended {
            return .restart
        }
        else {
            return .none
        }
    }
}
