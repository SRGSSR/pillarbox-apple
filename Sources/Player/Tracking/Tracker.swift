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

    @Published var playerItem: AVPlayerItem {
        didSet {
            metricEventCollector.playerItem = playerItem
        }
    }

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            if isEnabled {
                enable(mandatory: false)
                updateTrackersProperties(to: properties)
                updateTrackersMetricEvents(to: metricEventCollector.metricEvents)
            }
            else {
                disable(mandatory: false)
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

        enable(mandatory: true)
        if isEnabled {
            enable(mandatory: false)
        }
        configurePublishers()
    }

    private func enable(mandatory: Bool) {
        item.enableTrackers(mandatory: mandatory, for: player)
    }

    private func disable(mandatory: Bool) {
        item.disableTrackers(mandatory: mandatory, with: properties)
    }

    private func updateTrackersProperties(to properties: PlayerProperties) {
        item.updateTrackersProperties(mandatory: true, to: properties)
        if isEnabled {
            item.updateTrackersProperties(mandatory: false, to: properties)
        }
    }

    private func updateTrackersMetricEvents(to events: [MetricEvent]) {
        item.updateTrackersMetricEvents(mandatory: true, to: events)
        if isEnabled {
            item.updateTrackersMetricEvents(mandatory: false, to: events)
        }
    }

    private func configurePublishers() {
        $playerItem
            .map { [player] playerItem in
                playerItem.propertiesPublisher(with: player)
            }
            .switchToLatest()
            .handleEvents(receiveOutput: { [weak self] properties in
                // swiftlint:disable:previous trailing_closure
                self?.updateTrackersProperties(to: properties)
            })
            .weakAssign(to: \.properties, on: self)
            .store(in: &cancellables)
        metricEventCollector.$metricEvents
            .filter { !$0.isEmpty }
            .sink { [weak self] events in
                self?.updateTrackersMetricEvents(to: events)
            }
            .store(in: &cancellables)
    }

    deinit {
        if isEnabled {
            disable(mandatory: false)
        }
        disable(mandatory: true)
    }
}
