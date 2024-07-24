//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    private var cancellables = Set<AnyCancellable>()
    private let player: QueuePlayer
    var isEnabled = true {
        didSet {
            update(from: items, to: items, previouslyEnabled: oldValue, currentlyEnabled: isEnabled)
        }
    }

    var items: QueueItems? {
        didSet {
            update(from: oldValue, to: items, previouslyEnabled: isEnabled, currentlyEnabled: isEnabled)
        }
    }

    init(player: QueuePlayer) {
        self.player = player
    }

    private func update(from oldItems: QueueItems?, to newItems: QueueItems?, previouslyEnabled: Bool, currentlyEnabled: Bool) {
        cancellables = []

        if let oldItems {
            if previouslyEnabled, newItems?.item != oldItems.item {
                oldItems.item.disableTrackers(with: .empty, time: oldItems.playerItem.currentTime())
            }
            else if currentlyEnabled, !previouslyEnabled {
                oldItems.item.enableTrackers(for: player)
            }
        }

        if let newItems {
            if currentlyEnabled, oldItems?.item != newItems.item {
                newItems.item.enableTrackers(for: player)
            }
            else if previouslyEnabled && !currentlyEnabled {
                newItems.item.disableTrackers(with: .empty, time: newItems.playerItem.currentTime())
            }

            if currentlyEnabled {
                player.propertiesPublisher(with: newItems.playerItem)
                    .sink { properties in
                        newItems.item.updateTrackerProperties(with: properties, time: newItems.playerItem.currentTime())
                    }
                    .store(in: &cancellables)
            }
        }
    }

    deinit {
        guard let items else { return }
        items.item.disableTrackers(with: .empty, time: items.playerItem.currentTime())
    }
}
