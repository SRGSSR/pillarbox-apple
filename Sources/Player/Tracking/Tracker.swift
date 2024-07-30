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

    private var item: PlayerItem? {
        willSet {
            guard item != newValue else { return }
            disable(for: item)
        }
        didSet {
            guard isEnabled, item != oldValue else { return }
            enable(for: item)
        }
    }

    private var playerItem: AVPlayerItem? {
        didSet {
            guard isEnabled, playerItem != oldValue else { return }
            enable(for: playerItem)
        }
    }

    var queue: Queue = .empty {
        didSet {
            item = queue.item
            playerItem = queue.itemState.item
        }
    }

    var isEnabled: Bool {
        willSet {
            if isEnabled, isEnabled != newValue {
                disable(for: item)
            }
        }
        didSet {
            if isEnabled, isEnabled != oldValue {
                enable(for: item)
                enable(for: playerItem)
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

    private func enable(for item: PlayerItem?) {
        itemCancellables = []
        guard let item else { return }
        item.enableTrackers(for: player)
        item.metricEventPublisher()
            .sink { [metricEventSubject] event in
                metricEventSubject.send(event)
                item.receiveTrackerMetricEvent(event)
            }
            .store(in: &itemCancellables)
    }

    private func enable(for playerItem: AVPlayerItem?) {
        playerItemCancellables = []
        guard let playerItem else { return }
        playerItem.propertiesPublisher(with: player)
            .sink { [weak self] properties in
                guard let self else { return }
                item?.updateTrackerProperties(with: properties)
                self.properties = properties
            }
            .store(in: &playerItemCancellables)
        playerItem.metricEventPublisher()
            .sink { [weak self, metricEventSubject] event in
                guard let self else { return }
                metricEventSubject.send(event)
                item?.receiveTrackerMetricEvent(event)
            }
            .store(in: &playerItemCancellables)
    }

    private func disable(for item: PlayerItem?) {
        itemCancellables = []
        playerItemCancellables = []
        item?.disableTrackers(with: properties)
    }

    deinit {
        if isEnabled {
            disable(for: item)
        }
    }
}
