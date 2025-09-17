//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A navigation mode.
///
/// Controls the way items in a playback queue are navigated when the following navigation APIs are used:
///
///   - ``Player/returnToPreviousItem()``
///   - ``Player/advanceToNextItem()``
public enum NavigationMode: Equatable {
    /// Immediate navigation.
    case immediate

    /// Smart navigation.
    ///
    /// Makes ``Player/returnToPreviousItem()`` jump to the start position of the current item when within the first
    /// seconds of playback (as defined by the associated interval), otherwise returns to the previous item.
    ///
    /// > Note: This behavior is only meaningful for on-demand streams.
    case smart(interval: TimeInterval)
}
