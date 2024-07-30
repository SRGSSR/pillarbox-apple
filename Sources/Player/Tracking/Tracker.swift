//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class Tracker {
    private let player: QueuePlayer
    private var properties: PlayerProperties = .empty

    private let metricEventSubject = PassthroughSubject<MetricEvent, Never>()

    private var itemCancellables = Set<AnyCancellable>()
    private var playerItemCancellables = Set<AnyCancellable>()

    var items: QueueItems? {
        willSet {
            if items?.playerItem != newValue?.playerItem {
                disableForPlayerItem(in: items)
            }
            if items?.item != newValue?.item {
                disableForItem(in: items)
            }
        }
        didSet {
            guard isEnabled else { return }
            if items?.item != oldValue?.item {
                enableForItem(in: items)
            }
            if items?.playerItem != oldValue?.playerItem {
                enableForPlayerItem(in: items)
            }
        }
    }

    var isEnabled: Bool {
        willSet {
            if isEnabled, isEnabled != newValue {
                disableForPlayerItem(in: items)
                disableForItem(in: items)
            }
        }
        didSet {
            if isEnabled, isEnabled != oldValue {
                enableForItem(in: items)
                enableForPlayerItem(in: items)
            }
        }
    }

    var metricEventPublisher: AnyPublisher<MetricEvent, Never> {
        metricEventSubject.eraseToAnyPublisher()
    }

    init(player: QueuePlayer, isEnabled: Bool) {
        self.player = player
        self.isEnabled = isEnabled
    }

    deinit {
        if isEnabled {
            disableForPlayerItem(in: items)
            disableForItem(in: items)
        }
    }
}

private extension Tracker {
    func enableForItem(in items: QueueItems?) {
        guard let items else { return }

        items.item.enableTrackers(for: player)
        items.item.metricEventPublisher()
            .handleEvents(receiveOutput: { event in
                items.item.receiveTrackerMetricEvent(event)
            })
            .sink { [metricEventSubject] event in
                metricEventSubject.send(event)
            }
            .store(in: &itemCancellables)
    }

    func disableForItem(in items: QueueItems?) {
        itemCancellables = []
        items?.item.disableTrackers(with: properties)
    }
}

private extension Tracker {
    func enableForPlayerItem(in items: QueueItems?) {
        guard let items else { return }

        items.playerItem.propertiesPublisher(with: player)
            .handleEvents(receiveOutput: { properties in
                items.item.updateTrackerProperties(with: properties)
            })
            .weakAssign(to: \.properties, on: self)
            .store(in: &playerItemCancellables)

        items.playerItem.metricEventPublisher()
            .handleEvents(receiveOutput: { event in
                items.item.receiveTrackerMetricEvent(event)
            })
            .sink { [metricEventSubject] event in
                metricEventSubject.send(event)
            }
            .store(in: &playerItemCancellables)
    }

    func disableForPlayerItem(in items: QueueItems?) {
        playerItemCancellables = []
    }
}
