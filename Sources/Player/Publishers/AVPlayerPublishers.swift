//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVPlayer {
    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        publisher(for: \.currentItem)
            .removeDuplicates()
            .map { item -> AnyPublisher<ItemState, Never> in
                if let item {
                    if let error = item.error {
                        return Just(.init(item: item, error: error)).eraseToAnyPublisher()
                    }
                    else {
                        return item.errorPublisher()
                            .handleEvents(receiveOutput: { error in
                                guard let metricLog = item.metricLog else { return }
                                let payload = ErrorMetricPayload(level: .fatal, domain: .resource, error: error)
                                let event = MetricEvent(kind: .error(payload))
                                metricLog.addEvent(event)
                            })
                            .map { .init(item: item, error: $0) }
                            .prepend(.init(item: item, error: nil))
                            .eraseToAnyPublisher()
                    }
                }
                else {
                    return Just(.empty).eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .withPrevious(.empty)
            .map { state in
                // `AVQueuePlayer` sometimes consumes failed items, transitioning to `nil`, sometimes not. We can
                // make this behavior consistent by never consuming failed states.
                if state.current.item == nil && state.previous.error != nil {
                    return state.previous
                }
                else {
                    return state.current
                }
            }
            .eraseToAnyPublisher()
    }

    func playbackPropertiesPublisher() -> AnyPublisher<PlaybackProperties, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.rate),
            publisher(for: \.isExternalPlaybackActive),
            publisher(for: \.isMuted)
        )
        .map { .init(rate: $0, isExternalPlaybackActive: $1, isMuted: $2) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
