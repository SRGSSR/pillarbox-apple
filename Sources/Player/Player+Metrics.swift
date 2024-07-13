//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
import PillarboxCore

private let kMetricsQueue = DispatchQueue(label: "ch.srgssr.player.metrics")

public extension Player {
    /// A publisher delivering metric events associated with the current item.
    ///
    /// All metric events related to the item currently being played, if any, are received upon subscription.
    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        metricEventUpdatePublisher
            .map(\.events)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Returns a periodically updated metrics history associated with the current item.
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

#if compiler(>=6.0)
@available(iOS 18.0, tvOS 18.0, *)
public extension Player {
    /// A publisher delivering native metric events associated with the current item.
    var nativeMetricEventPublisher: AnyPublisher<AVMetricEvent, Never> {
        currentPlayerItemPublisher()
            .map { item -> AnyPublisher<AVMetricEvent, Never> in
                guard let item else { return Empty().eraseToAnyPublisher() }
                return item.nativeMetricEventPublisher()
                    .catch { _ in Empty() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    /// A publisher delivering native metric events of a given type associated with the current item.
    ///
    /// - Parameter type: The type of event.
    /// - Returns: The publisher.
    func nativeMetricEventPublisher<Event>(forType type: Event.Type) -> AnyPublisher<Event, Never> where Event: AVMetricEvent {
        currentPlayerItemPublisher()
            .map { item -> AnyPublisher<Event, Never> in
                guard let item else { return Empty().eraseToAnyPublisher() }
                return item.nativeMetricEventPublisher(forType: type)
                    .catch { _ in Empty() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    /// A publisher delivering native metric events of given types associated with the current item.
    ///
    /// - Parameters:
    ///   - firstType: The first type of event.
    ///   - secondType: The second type of event.
    ///   - otherTypes: As many other types of events as desired.
    /// - Returns: The publisher.
    func nativeMetricEventPublisher<FirstEvent, SecondEvent, each OtherEventPack>(
        forTypes firstType: FirstEvent.Type,
        _ secondType: SecondEvent.Type,
        _ otherTypes: repeat (each OtherEventPack).Type
    ) -> AnyPublisher<AVMetricEvent, Never>
    where FirstEvent: AVMetricEvent, SecondEvent: AVMetricEvent, repeat each OtherEventPack: AVMetricEvent {
        currentPlayerItemPublisher()
            .map { item -> AnyPublisher<AVMetricEvent, Never> in
                guard let item else { return Empty().eraseToAnyPublisher() }
                return item.nativeMetricEventPublisher(forTypes: firstType, secondType, repeat each otherTypes)
                    .catch { _ in Empty() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
#endif

extension Player {
    var metricEventPublisher: AnyPublisher<MetricEvent, Never> {
        metricEventUpdatePublisher
            .map(\.newEvents)
            .map { $0.publisher }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    private var metricEventUpdatePublisher: AnyPublisher<MetricEventUpdate, Never> {
        queuePublisher
            .slice(at: \.items)
            .withPrevious(nil)
            .compactMap { items -> AnyPublisher<MetricEventUpdate, Never> in
                guard let currentItems = items.current else {
                    return Just(.empty).eraseToAnyPublisher()
                }
                let update = QueueItems.metricEventUpdate(from: items.previous, to: currentItems)
                return currentItems.metricEventPublisher()
                    .scan(update) { $0.updated(with: $1) }
                    .prepend(update)
                    .filter { !$0.newEvents.isEmpty }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
