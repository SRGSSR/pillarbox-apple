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

    var queue: Queue = .empty {
        willSet {
            if queue.item != newValue.item {
                disable(with: queue)
            }
        }
        didSet {
            guard isEnabled else { return }
            if queue.item != oldValue.item {
                enable(with: queue)
                updateItemPublishers(for: queue)
            }
            if queue.itemState.item != oldValue.itemState.item {
                updatePlayerItemPublishers(for: queue)
            }
        }
    }

    var isEnabled: Bool {
        willSet {
            if isEnabled, isEnabled != newValue {
                disable(with: queue)
            }
        }
        didSet {
            if isEnabled, isEnabled != oldValue {
                enable(with: queue)
                updateItemPublishers(for: queue)
                updatePlayerItemPublishers(for: queue)
            }
        }
    }

    init(player: QueuePlayer, isEnabled: Bool) {
        self.player = player
        self.isEnabled = isEnabled
    }

    private func enable(with queue: Queue) {
        queue.item?.enableTrackers(for: player)
    }

    private func disable(with queue: Queue) {
        queue.item?.disableTrackers(with: properties)
    }

    private func updateItemPublishers(for queue: Queue) {
        itemCancellables = []
        guard let item = queue.item else { return }

        item.metricEventPublisher()
            .sink { event in
                item.receiveTrackerMetricEvent(event)
            }
            .store(in: &itemCancellables)
    }

    private func updatePlayerItemPublishers(for queue: Queue) {
        playerItemCancellables = []
        guard let playerItem = queue.itemState.item else { return }
        
        playerItem.propertiesPublisher(with: player)
            .sink { [weak self] properties in
                queue.item?.updateTrackerProperties(with: properties)
                self?.properties = properties
            }
            .store(in: &playerItemCancellables)
        playerItem.metricEventPublisher()
            .sink { event in
                queue.item?.receiveTrackerMetricEvent(event)
            }
            .store(in: &playerItemCancellables)
    }

    deinit {
        if isEnabled {
            disable(with: queue)
        }
    }
}
