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
    let queueItems: QueueItems
    private var cancellables = Set<AnyCancellable>()

    init(queueItems: QueueItems, player: Player) {
        self.queueItems = queueItems

        queueItems.item.enableTrackers(for: player)

        player.queuePlayer.propertiesPublisher(queueItems: queueItems)
            .sink { properties in
                queueItems.item.updateTrackerProperties(properties)
            }
            .store(in: &cancellables)
    }

    func release(player: Player) {
        // TODO: Provide playerItem.time explicitly since player.time probably invalid? But maybe not needed if
        // cleanup is explicit?
        queueItems.item.disableTrackers(for: player)
    }
}
