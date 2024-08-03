//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class MetricEventCollector {
    var playerItem: AVPlayerItem {
        didSet {
            configurePlayerItemPublisher()
        }
    }

    @Published private(set) var metricEvents: [MetricEvent] = []

    private var itemMetricEventSubject = PassthroughSubject<MetricEvent, Never>()
    private var playerItemMetricEventSubject = PassthroughSubject<MetricEvent, Never>()

    private var cancellables = Set<AnyCancellable>()
    private var playerItemCancellable: AnyCancellable?

    init(items: QueueItems) {
        playerItem = items.playerItem
        configurePublishers(for: items.item)
    }

    private func configurePublishers(for item: PlayerItem) {
        Publishers.Merge(itemMetricEventSubject, playerItemMetricEventSubject)
            .scan([]) { $0 + [$1] }
            .assign(to: &$metricEvents)
        item.metricEventPublisher()
            .assign(on: itemMetricEventSubject)
            .store(in: &cancellables)
        configurePlayerItemPublisher()
    }

    private func configurePlayerItemPublisher() {
        playerItemCancellable = playerItem.metricEventPublisher()
            .assign(on: playerItemMetricEventSubject)
    }
}
