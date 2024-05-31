//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A navigation mode.
///
/// Controls the way items in a queue are navigated when the smart navigation APIs are used. These include:
///
///   - ``Player/canReturnToPrevious()``
///   - ``Player/returnToPrevious()``
///   - ``Player/canAdvanceToNext()``
///   - ``Player/advanceToNext()``
public enum NavigationMode: Equatable {
    /// Standard navigation.
    ///
    /// Navigation between items is immediate.
    case immediate

    /// Smart navigation.
    ///
    /// Navigating back to a previous immediate is only immediate within the first seconds of playback, controlled
    /// by the specified interval.
    case smart(interval: TimeInterval)
}
