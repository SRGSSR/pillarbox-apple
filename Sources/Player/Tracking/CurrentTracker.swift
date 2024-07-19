//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// Tracks the provided item during its lifecycle.
///
/// This class implements a Resource Acquisition Is Initialization (RAII) approach to ensure lifecycle events are
/// properly balanced.
final class CurrentTracker {
    // TODO: Receive current QueueItems and observe, consolidating as properties
    let item: PlayerItem
    private var cancellables = Set<AnyCancellable>()

    init(item: PlayerItem, player: Player) {
        self.item = item
        item.enableTrackers(for: player)

        player.propertiesPublisher
            .sink { properties in
                item.updateTrackerProperties(properties)
            }
            .store(in: &cancellables)
    }

    func release(player: Player) {
        item.disableTrackers(for: player)
    }
}
