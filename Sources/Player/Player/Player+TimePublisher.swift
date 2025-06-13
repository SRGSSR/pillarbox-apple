//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia

public extension Player {
    /// Returns a publisher periodically emitting the current time while the player is playing content.
    ///
    /// - Parameters:
    ///   - interval: The interval at which events must be emitted, according to progress of the current time of the timebase.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    ///
    /// The publisher does not emit any value on subscription. Only valid times are emitted. Additional non-periodic
    /// updates will be published when time jumps or when playback starts or stops.
    func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: queuePlayer, interval: interval, queue: queue)
    }

    /// Returns a publisher emitting a void value when traversing the specified times during normal playback.
    /// 
    /// - Parameters:
    ///   - times: The times to observe.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    func boundaryTimePublisher(for times: [CMTime], queue: DispatchQueue = .main) -> AnyPublisher<Void, Never> {
        Publishers.BoundaryTimePublisher(for: queuePlayer, times: times, queue: queue)
    }
}

extension Player {
    func nextUnblockedTimePublisher() -> AnyPublisher<CMTime, Never> {
        metadataPublisher
            .slice(at: \.blockedTimeRanges)
            .map { [queuePlayer] blockedTimeRanges -> AnyPublisher<CMTime, Never> in
                guard !blockedTimeRanges.isEmpty else { return Empty().eraseToAnyPublisher() }
                return Publishers.PeriodicTimePublisher(for: queuePlayer, interval: .init(value: 1, timescale: 10))
                    .compactMap { $0.after(timeRanges: blockedTimeRanges) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
