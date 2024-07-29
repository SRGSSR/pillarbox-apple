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
    private var cancellables = Set<AnyCancellable>()

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
            }
            updatePublishers(for: items)
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
                updatePublishers(for: items)
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

    private func updatePublishers(for items: QueueItems?) {
        cancellables = []
        guard let items else { return }
        player.propertiesPublisher(with: items.playerItem)
            .sink { [weak self] properties in
                items.item.updateTrackerProperties(with: properties)
                self?.properties = properties
            }
            .store(in: &cancellables)
        
        items.metricEventPublisher()
            .sink { event in
                items.item.receiveTrackerMetricEvent(event)
            }
            .store(in: &cancellables)
    }

    deinit {
        if isEnabled {
            disable(with: items)
        }
    }
}
