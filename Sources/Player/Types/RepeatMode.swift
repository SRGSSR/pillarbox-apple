//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A mode setting how a player repeats playback of items in its queue.
public enum RepeatMode: CaseIterable {
    /// Disabled.
    case off

    /// Repeat the current item.
    case one

    /// Repeat all items.
    ///
    /// The behavior of player advance and return navigation methods is adjusted to wrap around both ends of the item
    /// queue.
    case all
}
