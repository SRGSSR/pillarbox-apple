//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class MetricEventCollector: NSObject {
    private let item: PlayerItem
    @objc dynamic var playerItem: AVPlayerItem

    @Published private(set) var metricEvents: [MetricEvent] = []

    init(items: QueueItems) {
        item = items.item
        playerItem = items.playerItem
        super.init()
        configureMetricEventsPublisher()
    }

    private func configureMetricEventsPublisher() {
        metricEventsPublisher()
            .assign(to: &$metricEvents)
    }

    private func metricEventsPublisher() -> AnyPublisher<[MetricEvent], Never> {
        Publishers.Merge(item.metricEventPublisher(), playerItemMetricEventPublisher())
            .scan([]) { $0 + [$1] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func playerItemMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        publisher(for: \.playerItem)
            .map { $0.metricEventPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
