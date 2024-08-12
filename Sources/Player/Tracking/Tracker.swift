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
                enable(behavior: .optional)
                updateTrackersProperties(to: properties)
                updateTrackersMetricEvents(to: metricEventCollector.metricEvents)
            }
            else {
                disable(behavior: .optional)
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

        enable(behavior: .mandatory)
        if isEnabled {
            enable(behavior: .optional)
        }
        configurePublishers()
    }

    private func enable(behavior: TrackingBehavior) {
        item.enableTrackers(behavior: behavior, for: player)
    }

    private func disable(behavior: TrackingBehavior) {
        item.disableTrackers(behavior: behavior, with: properties)
    }

    private func updateTrackersProperties(to properties: PlayerProperties) {
        item.updateTrackersProperties(behavior: .mandatory, to: properties)
        if isEnabled {
            item.updateTrackersProperties(behavior: .optional, to: properties)
        }
    }

    private func updateTrackersMetricEvents(to events: [MetricEvent]) {
        item.updateTrackersMetricEvents(behavior: .mandatory, to: events)
        if isEnabled {
            item.updateTrackersMetricEvents(behavior: .optional, to: events)
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
            disable(behavior: .optional)
        }
        disable(behavior: .mandatory)
    }
}
