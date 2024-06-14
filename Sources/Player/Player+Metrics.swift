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
    /// Returns a publisher periodically emitting metrics when the player is playing content.
    ///
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted, according to progress of the current time of the timebase.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    ///
    /// Additional non-periodic updates will be published when time jumps or when playback starts or stops.
    func periodicMetricsPublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<Metrics?, Never> {
        queuePlayer.currentItemPublisher()
            .map { [queuePlayer] item -> AnyPublisher<Metrics?, Never> in
                guard let item else { return Just(nil).eraseToAnyPublisher() }
                return Publishers.PeriodicTimePublisher(for: queuePlayer, interval: interval, queue: kMetricsQueue)
                    .scan(MetricsState.empty) { initial, next in
                        initial.updated(with: item.accessLog(), at: next) ?? initial
                    }
                    .removeDuplicates()
                    .withPrevious(MetricsState.empty)
                    .map { $0.current.metrics(from: $0.previous) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}
