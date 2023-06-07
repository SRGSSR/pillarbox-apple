//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

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
        time.isValid && timeRange.isValid && (time - timeRange.start).seconds >= Self.startTimeThreshold
    }

    func shouldSeekToStartTime() -> Bool {
        guard configuration.isSmartNavigationEnabled else { return false }
        return (streamType == .onDemand && isFarFromStartTime()) || !canReturnToPreviousItem()
    }
}
