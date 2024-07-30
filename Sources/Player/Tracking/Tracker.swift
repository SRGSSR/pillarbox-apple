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

    private func enableForItem(in items: QueueItems?) {
        guard let items else { return }
        items.item.enableTrackers(for: player)
        items.item.metricEventPublisher()
            .sink { [metricEventSubject] event in
                metricEventSubject.send(event)
                items.item.receiveTrackerMetricEvent(event)
            }
            .store(in: &itemCancellables)
    }

    private func disableForItem(in items: QueueItems?) {
        itemCancellables = []
        items?.item.disableTrackers(with: properties)
    }

    private func enableForPlayerItem(in items: QueueItems?) {
        guard let items else { return }
        items.playerItem.propertiesPublisher(with: player)
            .sink { [weak self] properties in
                guard let self else { return }
                items.item.updateTrackerProperties(with: properties)
                self.properties = properties
            }
            .store(in: &playerItemCancellables)
        items.playerItem.metricEventPublisher()
            .sink { [metricEventSubject] event in
                metricEventSubject.send(event)
                items.item.receiveTrackerMetricEvent(event)
            }
            .store(in: &playerItemCancellables)
    }

    private func disableForPlayerItem(in items: QueueItems?) {
        playerItemCancellables = []
    }

    deinit {
        if isEnabled {
            disableForPlayerItem(in: items)
            disableForItem(in: items)
        }
    }
}
