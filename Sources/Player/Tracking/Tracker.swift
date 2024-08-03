//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class Tracker {
    let item: PlayerItem

    var playerItem: AVPlayerItem {
        didSet {
            metricEventCollector.playerItem = playerItem
        }
    }

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            if isEnabled {
                item.enableTrackers(for: player)
            }
            else {
                item.disableTrackers(with: properties)
            }
        }
    }

    private let player: QueuePlayer
    private let metricEventCollector: MetricEventCollector
    private var properties: PlayerProperties = .empty

    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        metricEventCollector.$metricEvents.eraseToAnyPublisher()
    }

    init(items: QueueItems, player: QueuePlayer, isEnabled: Bool) {
        self.item = items.item
        self.playerItem = items.playerItem

        self.player = player
        self.isEnabled = isEnabled

        self.metricEventCollector = MetricEventCollector(items: items)
        
        if isEnabled {
            item.enableTrackers(for: player)
        }
    }

    deinit {
        if isEnabled {
            item.disableTrackers(with: properties)
        }
    }
}
