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
    let item: PlayerItem
    private var cancellables = Set<AnyCancellable>()

    init?(item: PlayerItem, player: Player?) {
        guard let player else { return nil }
        self.item = item

        item.$content
            .sink { content in
                content.updateTracker()
            }
            .store(in: &cancellables)
        item.content.enableTrackers(for: player)
    }

    deinit {
        item.content.disableTrackers()
    }
}
