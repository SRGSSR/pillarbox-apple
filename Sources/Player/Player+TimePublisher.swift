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
    ///   - interval: The interval at which events must be emitted.
    ///   - queue: The queue on which values are published.
    /// - Returns: The publisher.
    ///
    /// The publisher does not emit any value on subscription. Only valid times are emitted.
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
        metadataPublisher.map { [queuePlayer] metadata -> AnyPublisher<CMTime, Never> in
            guard !metadata.blockedTimeRanges.isEmpty else { return Empty().eraseToAnyPublisher() }
            return Publishers.PeriodicTimePublisher(for: queuePlayer, interval: .init(value: 1, timescale: 10))
                .compactMap { time in
                    time.after(timeRanges: metadata.blockedTimeRanges.map { timeRange in
                        CMTimeRange(start: timeRange.start, end: timeRange.end)
                    })
                }
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
