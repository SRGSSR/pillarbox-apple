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
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canReturnToPreviousItem() -> Bool {
        canReturnToItem(before: currentItem, in: storedItems)
    }

    /// Returns to the previous item in the queue.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func returnToPreviousItem() {
        guard let index = index(before: currentItem, in: storedItems) else { return }
        queuePlayer.replaceItems(
            with: AVPlayerItem.playerItems(
                from: Array(storedItems),
                after: index,
                repeatMode: repeatMode,
                length: configuration.preloadedItems,
                reload: true,
                configuration: configuration
            )
        )
    }

    /// Checks whether moving to the next item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canAdvanceToNextItem() -> Bool {
        canAdvanceToItem(after: currentItem, in: storedItems)
    }

    /// Moves to the next item in the queue.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Ignores the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func advanceToNextItem() {
        guard let index = index(after: currentItem, in: storedItems) else { return }
        queuePlayer.replaceItems(
            with: AVPlayerItem.playerItems(
                from: Array(storedItems),
                after: index,
                repeatMode: repeatMode,
                length: configuration.preloadedItems,
                reload: true,
                configuration: configuration
            )
        )
    }
}

extension Player {
    func canReturnToItem(before item: PlayerItem?, in items: Deque<PlayerItem>) -> Bool {
        index(before: item, in: items) != nil
    }

    func canAdvanceToItem(after item: PlayerItem?, in items: Deque<PlayerItem>) -> Bool {
        index(after: item, in: items) != nil
    }

    func replaceCurrentItemWithItem(_ item: PlayerItem?) {
        if let item {
            if let index = storedItems.firstIndex(of: item) {
                let playerItems = AVPlayerItem.playerItems(
                    from: Array(storedItems),
                    after: index,
                    repeatMode: repeatMode,
                    length: configuration.preloadedItems,
                    reload: true,
                    configuration: configuration
                )
                queuePlayer.replaceItems(with: playerItems)
            }
            else if let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) {
                storedItems[currentIndex] = item
            }
        }
        else {
            queuePlayer.removeAllItems()
        }
    }

    func reloadItems() {
        let contents = Array(storedItems).map(\.content)
        let items = AVPlayerItem.playerItems(
            for: contents,
            replacing: contents,
            currentItem: queuePlayer.currentItem,
            repeatMode: repeatMode,
            length: configuration.preloadedItems,
            configuration: configuration
        )
        queuePlayer.replaceItems(with: items)
    }
}

private extension Player {
    func index(before item: PlayerItem?, in items: Deque<PlayerItem>) -> Int? {
        guard let item, let index = items.firstIndex(of: item) else { return nil }
        let previousIndex = items.index(before: index)
        return previousIndex >= items.startIndex ? previousIndex : beforeIndex()
    }

    func index(after item: PlayerItem?, in items: Deque<PlayerItem>) -> Int? {
        guard let item, let index = items.firstIndex(of: item) else { return nil }
        let nextIndex = items.index(after: index)
        return nextIndex < items.endIndex ? nextIndex : afterIndex()
    }

    func afterIndex() -> Int? {
        switch repeatMode {
        case .off, .one:
            return nil
        case .all:
            return items.startIndex
        }
    }

    func beforeIndex() -> Int? {
        switch repeatMode {
        case .off, .one:
            return nil
        case .all:
            return items.index(before: items.endIndex)
        }
    }
}
