//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Tracks the provided item during its lifecycle.
///
/// This class implements a Resource Acquisition Is Initialization (RAII) approach to ensure lifecycle events are
/// properly balanced.
final class CurrentTracker {
    let item: PlayerItem

    init?(item: PlayerItem, player: Player?) {
        guard let player else { return nil }
        self.item = item
        item.enableTrackers(for: player)
    }

    deinit {
        item.disableTrackers()
    }
}
