//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import DequeModule
import Foundation

public extension Player {
    /// Checks whether returning to the previous content is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// Performs smart navigation if enabled in the ``PlayerConfiguration``. Smart navigation takes into account the
    /// current position in an item. If close enough to the item start position then navigation will be moved to the
    /// previous item, otherwise playback will be returned to the item start position. This behavior is only applied
    /// for on-demand streams.
    func canReturnToPrevious() -> Bool {
        canReturn(before: currentIndex, in: storedItems, streamType: streamType)
    }

    /// Returns to the previous content.
    ///
    /// Performs smart navigation if enabled in the ``PlayerConfiguration``. Smart navigation takes into account the
    /// current position in an item. If close enough to the item start position then navigation will be moved to the
    /// previous item, otherwise playback will be returned to the item start position. This behavior is only applied
    /// for on-demand streams.
    func returnToPrevious() {
        if shouldSeekToStartTime() {
            seek(near(.zero))
        }
        else {
            returnToPreviousItem()
        }
    }

    /// Checks whether moving to the next content is possible.
    ///
    /// - Returns: `true` if possible.
    func canAdvanceToNext() -> Bool {
        canAdvanceToNextItem()
    }

    /// Moves to the next content.
    func advanceToNext() {
        advanceToNextItem()
    }
}

extension Player {
    func canReturn(before index: Int?, in items: Deque<PlayerItem>, streamType: StreamType) -> Bool {
        if configuration.isSmartNavigationEnabled && streamType == .onDemand {
            return true
        }
        else {
            return canReturnToItem(before: index, in: items)
        }
    }

    func canAdvance(after index: Int?, in items: Deque<PlayerItem>) -> Bool {
        canAdvanceToItem(after: index, in: items)
    }
}

private extension Player {
    static let startTimeThreshold: TimeInterval = 3

    func isFarFromStartTime() -> Bool {
        time.isValid && seekableTimeRange.isValid && (time - seekableTimeRange.start).seconds >= Self.startTimeThreshold
    }

    func shouldSeekToStartTime() -> Bool {
        guard configuration.isSmartNavigationEnabled else { return false }
        return (streamType == .onDemand && isFarFromStartTime()) || !canReturnToPreviousItem()
    }
}
