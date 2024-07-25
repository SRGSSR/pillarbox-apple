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
    private var properties: PlayerProperties = .empty

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
                oldItems.item.disableTrackers(with: properties)
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
                newItems.item.disableTrackers(with: properties)
            }

            if currentlyEnabled {
                player.propertiesPublisher(with: newItems.playerItem)
                    .sink { [weak self] properties in
                        newItems.item.updateTrackerProperties(with: properties)
                        self?.properties = properties
                    }
                    .store(in: &cancellables)
            }
        }
    }

    deinit {
        items?.item.disableTrackers(with: properties)
    }
}
