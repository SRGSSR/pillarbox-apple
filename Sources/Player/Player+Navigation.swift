//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

public extension Player {
    /// Check whether returning to the previous item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPreviousItem() -> Bool {
        Self.canReturnToItem(before: currentIndex, in: storedItems)
    }

    /// Return to the previous item in the deque. Skips failed items.
    func returnToPreviousItem() {
        guard canReturnToPreviousItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: returningItems))
    }

    /// Check whether moving to the next item in the deque is possible.`
    /// - Returns: `true` if possible.
    func canAdvanceToNextItem() -> Bool {
        canAdvanceToItem(after: currentIndex, in: storedItems)
    }

    /// Move to the next item in the deque.
    func advanceToNextItem() {
        guard canAdvanceToNextItem() else { return }
        queuePlayer.replaceItems(with: AVPlayerItem.playerItems(from: advancingItems))
    }
}

public extension Player {
    /// Check whether returning to the previous content is possible.`
    /// - Returns: `true` if possible.
    func canReturnToPrevious() -> Bool {
        canReturn(before: currentIndex, in: storedItems, streamType: streamType)
    }

    /// Return to the previous content.
    func returnToPrevious() {
        if shouldSeekToStartTime() {
            seek(near(.zero))
        }
        else {
            returnToPreviousItem()
        }
    }

    /// Check whether moving to the next content is possible.`
    /// - Returns: `true` if possible.
    func canAdvanceToNext() -> Bool {
        canAdvanceToNextItem()
    }

    /// Move to the next content.
    func advanceToNext() {
        advanceToNextItem()
    }

    /// Set the index of the current item.
    /// - Parameter index: The index to set.
    func setCurrentIndex(_ index: Int) throws {
        guard index != currentIndex else { return }
        guard (0..<storedItems.count).contains(index) else { throw PlaybackError.itemOutOfBounds }
        let playerItems = AVPlayerItem.playerItems(from: Array(storedItems.suffix(from: index)))
        queuePlayer.replaceItems(with: playerItems)
    }
}

extension Player {
    func canReturn(before index: Int?, in items: Deque<PlayerItem>, streamType: StreamType) -> Bool {
        if configuration.isSmartNavigationEnabled && streamType == .onDemand {
            return true
        }
        else {
            return Self.canReturnToItem(before: index, in: items)
        }
    }

    func canAdvanceToItem(after index: Int?, in items: Deque<PlayerItem>) -> Bool {
        !Self.items(after: index, in: items).isEmpty
    }
}

private extension Player {
    static let startTimeThreshold: TimeInterval = 3

    /// Return the list of items to be loaded to return to the previous (playable) item.
    var returningItems: [PlayerItem] {
        Self.items(before: currentIndex, in: storedItems)
    }

    /// Return the list of items to be loaded to advance to the next (playable) item.
    var advancingItems: [PlayerItem] {
        Self.items(after: currentIndex, in: storedItems)
    }

    static func canReturnToItem(before index: Int?, in items: Deque<PlayerItem>) -> Bool {
        !Self.items(before: index, in: items).isEmpty
    }

    private func isFarFromStartTime() -> Bool {
        time.isValid && timeRange.isValid && (time - timeRange.start).seconds >= Self.startTimeThreshold
    }

    private func shouldSeekToStartTime() -> Bool {
        guard configuration.isSmartNavigationEnabled else { return false }
        return (streamType == .onDemand && isFarFromStartTime()) || !canReturnToPreviousItem()
    }
}
