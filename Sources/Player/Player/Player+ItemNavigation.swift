//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

public extension Player {
    /// Checks whether returning to the previous content is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canReturnToPreviousItem() -> Bool {
        canReturnToItem(before: currentItem, in: storedItems, streamType: streamType)
    }

    /// Returns to the previous content.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func returnToPreviousItem() {
        if shouldSeekToStartTime() {
            seek(near(.zero))
        }
        else if let previousIndex = index(before: currentItem, in: storedItems) {
            queuePlayer.replaceItems(
                with: AVPlayerItem.playerItems(
                    from: Array(storedItems),
                    after: previousIndex,
                    repeatMode: repeatMode,
                    length: configuration.preloadedItems,
                    reload: true,
                    configuration: configuration,
                    resumeState: resumeState,
                    limits: limits
                )
            )
        }
    }

    /// Checks whether moving to the next content is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canAdvanceToNextItem() -> Bool {
        canAdvanceToItem(after: currentItem, in: storedItems)
    }

    /// Moves to the next content.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``Player/repeatMode``
    /// has been set to ``RepeatMode/all``.
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func advanceToNextItem() {
        guard let index = index(after: currentItem, in: storedItems) else { return }
        queuePlayer.replaceItems(
            with: AVPlayerItem.playerItems(
                from: Array(storedItems),
                after: index,
                repeatMode: repeatMode,
                length: configuration.preloadedItems,
                reload: true,
                configuration: configuration,
                resumeState: resumeState,
                limits: limits
            )
        )
    }
}

extension Player {
    func canReturnToItem(before item: PlayerItem?, in items: Deque<PlayerItem>, streamType: StreamType) -> Bool {
        switch configuration.navigationMode {
        case .smart where streamType == .onDemand:
            return true
        default:
            return index(before: item, in: items) != nil
        }
    }

    func canAdvanceToItem(after item: PlayerItem?, in items: Deque<PlayerItem>) -> Bool {
        index(after: item, in: items) != nil
    }
}

private extension Player {
    func isAwayFromStartTime(withInterval interval: TimeInterval) -> Bool {
        let time = time()
        return time.isValid && seekableTimeRange.isValid && (time - seekableTimeRange.start).seconds >= interval
    }

    func shouldSeekToStartTime() -> Bool {
        switch configuration.navigationMode {
        case .immediate:
            return false
        case let .smart(interval: interval):
            return (streamType == .onDemand && isAwayFromStartTime(withInterval: interval)) || index(before: currentItem, in: storedItems) == nil
        }
    }
}

extension Player {
    func replaceCurrentItemWithItem(_ item: PlayerItem?) {
        if let item {
            if let index = storedItems.firstIndex(of: item) {
                let playerItems = AVPlayerItem.playerItems(
                    from: Array(storedItems),
                    after: index,
                    repeatMode: repeatMode,
                    length: configuration.preloadedItems,
                    reload: true,
                    configuration: configuration,
                    resumeState: resumeState,
                    limits: limits
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
            configuration: configuration,
            resumeState: resumeState,
            limits: limits
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

    func beforeIndex() -> Int? {
        switch repeatMode {
        case .off, .one:
            return nil
        case .all:
            return items.index(before: items.endIndex)
        }
    }

    func afterIndex() -> Int? {
        switch repeatMode {
        case .off, .one:
            return nil
        case .all:
            return items.startIndex
        }
    }
}
