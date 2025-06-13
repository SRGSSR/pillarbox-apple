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
    /// A publisher delivering metric events associated with the current item.
    ///
    /// All metric events related to the item currently being played, if any, are received upon subscription.
    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        $tracker
            .map { tracker -> AnyPublisher<[MetricEvent], Never> in
                guard let tracker else { return Just([]).eraseToAnyPublisher() }
                return tracker.metricEventsPublisher
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// The current player metrics, if available.
    ///
    /// Each call to this function might return different results reflecting the most recent metrics available. The
    /// included ``Metrics/increment`` collates data from the entire playback session and is therefore always equal
    /// to ``Metrics/total``.
    ///
    /// > Important: Metrics are reset when toggling external playback.
    func metrics() -> Metrics? {
        properties.metrics()
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
    ///
    /// > Important: The metrics history is reset when toggling external playback.
    func periodicMetricsPublisher(forInterval interval: CMTime, queue: DispatchQueue = .main, limit: Int = .max) -> AnyPublisher<[Metrics], Never> {
        Publishers.CombineLatest(
            currentPlayerItemPublisher(),
            queuePlayer.publisher(for: \.isExternalPlaybackActive)
        )
        .map { [queuePlayer] item, _ -> AnyPublisher<[Metrics], Never> in
            guard let item, item.isLoaded else { return Just([]).eraseToAnyPublisher() }
            return Publishers.PeriodicTimePublisher(for: queuePlayer, interval: interval, queue: kMetricsQueue)
                .compactMap { _ in MetricsState(from: item) }
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
