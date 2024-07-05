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
    ///   - interval: The interval at which events must be emitted, according to progress of the current time of the timebase.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    ///
    /// Additional non-periodic updates will be published when time jumps or when playback starts or stops. Each
    /// included ``Metrics/increment`` collates data since the previous periodic update.
    func periodicMetricsPublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<[Metrics], Never> {
        currentPlayerItemPublisher()
            .map { [queuePlayer] item -> AnyPublisher<[Metrics], Never> in
                guard let item else { return Just([]).eraseToAnyPublisher() }
                return Publishers.PeriodicTimePublisher(for: queuePlayer, interval: interval, queue: kMetricsQueue)
                    .scan(MetricsState.empty) { state, time in
                        state.updated(with: item.accessLog(), at: time)
                    }
                    .withPrevious(MetricsState.empty)
                    .map { $0.current.metrics(from: $0.previous) }
                    .scan([]) { $0 + [$1] }
                    .prepend([])
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}
