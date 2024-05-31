//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

public extension Player {
    /// Checks whether returning to the previous item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canReturnToPreviousItem() -> Bool {
        canReturnToItem(before: currentIndex, in: storedItems)
    }

    /// Returns to the previous item in the queue.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func returnToPreviousItem() {
        guard canReturnToPreviousItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: returningItems, length: configuration.preloadedItems, reload: true))
    }

    /// Checks whether moving to the next item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canAdvanceToNextItem() -> Bool {
        canAdvanceToItem(after: currentIndex, in: storedItems)
    }

    /// Moves to the next item in the queue.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func advanceToNextItem() {
        guard canAdvanceToNextItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: advancingItems, length: configuration.preloadedItems, reload: true))
    }

    /// Makes the item at the specified index the current one.
    ///
    /// - Parameter index: The item index.
    func setCurrentIndex(_ index: Int) throws {
        guard (0..<storedItems.count).contains(index) else { throw PlaybackError.itemOutOfBounds }
        let playerItems = AVPlayerItem.playerItems(from: Array(storedItems.suffix(from: index)), length: configuration.preloadedItems, reload: true)
        queuePlayer.replaceItems(with: playerItems)
    }
}

extension Player {
    func canReturnToItem(before index: Int?, in items: Deque<PlayerItem>) -> Bool {
        !Self.items(before: index, in: items).isEmpty
    }

    func canAdvanceToItem(after index: Int?, in items: Deque<PlayerItem>) -> Bool {
        !Self.items(after: index, in: items).isEmpty
    }
}

private extension Player {
    /// Returns the list of items to be loaded to return to the previous (playable) item.
    var returningItems: [PlayerItem] {
        Self.items(before: currentIndex, in: storedItems)
    }

    /// Returns the list of items to be loaded to advance to the next (playable) item.
    var advancingItems: [PlayerItem] {
        Self.items(after: currentIndex, in: storedItems)
    }

    static func items(before index: Int?, in items: Deque<PlayerItem>) -> [PlayerItem] {
        guard let index else { return [] }
        let previousIndex = items.index(before: index)
        guard previousIndex >= 0 else { return [] }
        return Array(items.suffix(from: previousIndex))
    }

    static func items(after index: Int?, in items: Deque<PlayerItem>) -> [PlayerItem] {
        guard let index else { return [] }
        let nextIndex = items.index(after: index)
        guard nextIndex < items.count else { return [] }
        return Array(items.suffix(from: nextIndex))
    }
}
