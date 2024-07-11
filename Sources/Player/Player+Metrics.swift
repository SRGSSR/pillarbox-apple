//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import PillarboxCore

private let kMetricsQueue = DispatchQueue(label: "ch.srgssr.player.metrics")

public extension Player {
    /// Returns a periodically updated metrics history associated to the current item.
    ///
    /// - Parameters:
    ///   - interval: The interval at which the history should be updated, according to progress of the current time of
    ///     the timebase.
    ///   - queue: The queue on which values are published.
    ///   - limit: The maximum number of metrics to keep in the history.
    /// - Returns: The publisher.
    ///
    /// Additional non-periodic updates will be published when time jumps or when playback starts or stops. Each
    /// included ``Metrics/increment`` collates data since the entry that precedes it in the history. No updates are
    /// published if no metrics are provided for the item being played.
    func periodicMetricsPublisher(forInterval interval: CMTime, queue: DispatchQueue = .main, limit: Int = .max) -> AnyPublisher<[Metrics], Never> {
        currentPlayerItemPublisher()
            .map { [queuePlayer] item -> AnyPublisher<[Metrics], Never> in
                guard let item else { return Just([]).eraseToAnyPublisher() }
                return Publishers.PeriodicTimePublisher(for: queuePlayer, interval: interval, queue: kMetricsQueue)
                    .compactMap { _ in item.accessLog()?.events }
                    .filter { !$0.isEmpty }
                    .scan(MetricsState.empty) { state, events in
                        state.updated(with: events, at: item.currentTime())
                    }
                    .withPrevious(MetricsState.empty)
                    .map { $0.current.metrics(from: $0.previous) }
                    .scan([]) { ($0 + [$1]).suffix(limit) }
                    .prepend([])
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}

public extension Player {
    /// A publisher delivering metric events for the current item.
    ///
    /// All metric events related to the item currently being played, if any, are received upon subscription.
    var currentMetricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        metricEventUpdatePublisher
            .map(\.events)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// A publisher delivering new metric events.
    ///
    /// All metric events related to the item currently being played, if any, are received upon subscription.
    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        metricEventUpdatePublisher
            .map(\.newEvents)
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private var metricEventUpdatePublisher: AnyPublisher<MetricEventUpdate, Never> {
        queuePublisher
            .withPrevious(.empty)
            .map { queue -> AnyPublisher<MetricEventUpdate, Never> in
                guard let items = queue.current.items else {
                    return Just(.empty).eraseToAnyPublisher()
                }
                let update = QueueItems.metricEventUpdate(from: queue.previous.items, to: items)
                return items.metricEventPublisher()
                    .scan(update) { $0.updated(with: $1) }
                    .prepend(update)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
