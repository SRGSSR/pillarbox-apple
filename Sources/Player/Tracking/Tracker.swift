//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    private let player: QueuePlayer
    private var properties: PlayerProperties = .empty

    private var itemCancellables = Set<AnyCancellable>()
    private var playerItemCancellables = Set<AnyCancellable>()

    var items: QueueItems? {
        willSet {
            if items?.item != newValue?.item {
                disable(with: items)
            }
        }
        didSet {
            guard isEnabled else { return }
            if items?.item != oldValue?.item {
                enable(with: items)
                updateItemPublishers(for: items)
            }
            updatePlayerItemPublishers(for: items)
        }
    }

    var isEnabled: Bool {
        willSet {
            if isEnabled, isEnabled != newValue {
                disable(with: items)
            }
        }
        didSet {
            if isEnabled, isEnabled != oldValue {
                enable(with: items)
                updateItemPublishers(for: items)
                updatePlayerItemPublishers(for: items)
            }
        }
    }

    init(player: QueuePlayer, isEnabled: Bool) {
        self.player = player
        self.isEnabled = isEnabled
    }

    private func enable(with items: QueueItems?) {
        items?.item.enableTrackers(for: player)
    }

    private func disable(with items: QueueItems?) {
        items?.item.disableTrackers(with: properties)
    }

    private func updateItemPublishers(for items: QueueItems?) {
        itemCancellables = []
        guard let items else { return }

        items.item
            .metricEventPublisher()
            .sink { event in
                items.item.receiveTrackerMetricEvent(event)
            }
            .store(in: &itemCancellables)
    }

    private func updatePlayerItemPublishers(for items: QueueItems?) {
        playerItemCancellables = []
        guard let items else { return }

        player.propertiesPublisher(with: items.playerItem)
            .sink { [weak self] properties in
                items.item.updateTrackerProperties(with: properties)
                self?.properties = properties
            }
            .store(in: &playerItemCancellables)
        items.playerItem
            .metricEventPublisher()
            .sink { event in
                items.item.receiveTrackerMetricEvent(event)
            }
            .store(in: &playerItemCancellables)
    }

    deinit {
        if isEnabled {
            disable(with: items)
        }
    }
}
