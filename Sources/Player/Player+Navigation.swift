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
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canReturnToPrevious() -> Bool {
        canReturn(before: currentIndex, in: storedItems, streamType: streamType)
    }

    /// Returns to the previous content.
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
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
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func canAdvanceToNext() -> Bool {
        canAdvanceToNextItem()
    }

    /// Moves to the next content.
    ///
    /// > Important: Observes the ``PlayerConfiguration/navigationMode`` set in the ``Player/configuration``.
    func advanceToNext() {
        advanceToNextItem()
    }
}

extension Player {
    func canReturn(before index: Int?, in items: Deque<PlayerItem>, streamType: StreamType) -> Bool {
        switch configuration.navigationMode {
        case .smart where streamType == .onDemand:
            return true
        default:
            return canReturnToItem(before: index, in: items)
        }
    }

    func canAdvance(after index: Int?, in items: Deque<PlayerItem>) -> Bool {
        canAdvanceToItem(after: index, in: items)
    }
}

private extension Player {
    func isAwayFromStartTime(withInterval interval: TimeInterval) -> Bool {
        time.isValid && seekableTimeRange.isValid && (time - seekableTimeRange.start).seconds >= interval
    }

    func shouldSeekToStartTime() -> Bool {
        switch configuration.navigationMode {
        case .immediate:
            return false
        case let .smart(interval: interval):
            return (streamType == .onDemand && isAwayFromStartTime(withInterval: interval)) || !canReturnToPreviousItem()
        }
    }
}
