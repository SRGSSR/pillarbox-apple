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
                enableTrackers(matchingBehavior: .optional)
                item.updateTrackersProperties(matchingBehavior: .optional, to: properties)
                item.updateTrackersMetricEvents(matchingBehavior: .optional, to: metricEventCollector.metricEvents)
            }
            else {
                disableTrackers(matchingBehavior: .optional)
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

        enableTrackers(matchingBehavior: .mandatory)
        if isEnabled {
            enableTrackers(matchingBehavior: .optional)
        }
        configurePublishers()
    }

    private func enableTrackers(matchingBehavior behavior: TrackingBehavior) {
        item.enableTrackers(matchingBehavior: behavior, for: player)
    }

    private func disableTrackers(matchingBehavior behavior: TrackingBehavior) {
        item.disableTrackers(matchingBehavior: behavior, with: properties)
    }

    private func updateTrackersProperties(to properties: PlayerProperties) {
        item.updateTrackersProperties(matchingBehavior: .mandatory, to: properties)
        if isEnabled {
            item.updateTrackersProperties(matchingBehavior: .optional, to: properties)
        }
    }

    private func updateTrackersMetricEvents(to events: [MetricEvent]) {
        item.updateTrackersMetricEvents(matchingBehavior: .mandatory, to: events)
        if isEnabled {
            item.updateTrackersMetricEvents(matchingBehavior: .optional, to: events)
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
            disableTrackers(matchingBehavior: .optional)
        }
        disableTrackers(matchingBehavior: .mandatory)
    }
}
