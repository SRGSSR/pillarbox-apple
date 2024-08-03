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
            guard playerItem != oldValue else { return }
            configurePlayerItemPublisher(for: playerItem)
        }
    }

    @Published private(set) var metricEvents: [MetricEvent] = []

    private var itemMetricEventSubject = PassthroughSubject<MetricEvent, Never>()
    private var playerItemMetricEventSubject = PassthroughSubject<MetricEvent, Never>()

    private var cancellables = Set<AnyCancellable>()
    private var playerItemCancellable: AnyCancellable?

    init(items: QueueItems) {
        playerItem = items.playerItem
        configurePublishers(for: items)
    }

    private func configurePublishers(for items: QueueItems) {
        Publishers.Merge(itemMetricEventSubject, playerItemMetricEventSubject)
            .scan([]) { $0 + [$1] }
            .removeDuplicates()
            .assign(to: &$metricEvents)
        items.item.metricEventPublisher()
            .assign(on: itemMetricEventSubject)
            .store(in: &cancellables)
        configurePlayerItemPublisher(for: items.playerItem)
    }

    private func configurePlayerItemPublisher(for playerItem: AVPlayerItem) {
        playerItemCancellable = playerItem.metricEventPublisher()
            .assign(on: playerItemMetricEventSubject)
    }
}
