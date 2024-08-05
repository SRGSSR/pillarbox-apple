//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class MetricEventCollector {
    private let item: PlayerItem

    @Published var playerItem: AVPlayerItem
    @Published private(set) var metricEvents: [MetricEvent] = []

    init(items: QueueItems) {
        item = items.item
        playerItem = items.playerItem
        configureMetricEventsPublisher()
    }

    private func configureMetricEventsPublisher() {
        Publishers.Merge(item.metricEventPublisher(), playerItemMetricEventPublisher())
            .scan([]) { $0 + [$1] }
            .assign(to: &$metricEvents)
    }

    private func playerItemMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        $playerItem
            .map { $0.metricEventPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
