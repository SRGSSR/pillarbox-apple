//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class Tracker: NSObject {
    let item: PlayerItem

    @objc dynamic var playerItem: AVPlayerItem {
        didSet {
            metricEventCollector.playerItem = playerItem
        }
    }

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            if isEnabled {
                enable()
            }
            else {
                disable()
            }
        }
    }

    private let player: QueuePlayer
    private let metricEventCollector: MetricEventCollector
    private var properties: PlayerProperties = .empty
    private var cancellables = Set<AnyCancellable>()

    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        metricEventCollector.$metricEvents.eraseToAnyPublisher()
    }

    init(items: QueueItems, player: QueuePlayer, isEnabled: Bool) {
        self.item = items.item
        self.playerItem = items.playerItem
        self.player = player
        self.isEnabled = isEnabled
        self.metricEventCollector = MetricEventCollector(items: items)
        super.init()

        if isEnabled {
            enable()
        }
    }

    private func enable() {
        item.enableTrackers(for: player)
        metricEventCollector.$metricEvents
            .filter { !$0.isEmpty }
            .sink { [item] events in
                item.updateTrackersMetricEvents(to: events)
            }
            .store(in: &cancellables)
        publisher(for: \.playerItem)
            .map { [player] playerItem in
                playerItem.propertiesPublisher(with: player)
            }
            .switchToLatest()
            .handleEvents(receiveOutput: { [item] properties in
                // swiftlint:disable:previous trailing_closure
                item.updateTrackersProperties(to: properties)
            })
            .weakAssign(to: \.properties, on: self)
            .store(in: &cancellables)
    }

    private func disable() {
        cancellables = []
        item.disableTrackers(with: properties)
    }

    deinit {
        if isEnabled {
            disable()
        }
    }
}
