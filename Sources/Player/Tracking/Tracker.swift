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
            guard playerItem != oldValue else { return }
            metricEventCollector.playerItem = playerItem
            unregisterPublishers()
            if isEnabled {
                registerPublishers()
            }
        }
    }

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            if isEnabled {
                enable()
                registerPublishers()
            }
            else {
                unregisterPublishers()
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
        
        if isEnabled {
            enable()
            registerPublishers()
        }
    }

    private func enable() {
        item.enableTrackers(for: player)
    }

    private func disable() {
        item.disableTrackers(with: properties)
    }

    private func registerPublishers() {
        playerItem.propertiesPublisher(with: player)
            .handleEvents(receiveOutput: { [item] properties in
                item.updateTrackerProperties(with: properties)
            })
            .weakAssign(to: \.properties, on: self)
            .store(in: &cancellables)
    }

    private func unregisterPublishers() {
        cancellables = []
    }

    deinit {
        if isEnabled {
            disable()
        }
    }
}
