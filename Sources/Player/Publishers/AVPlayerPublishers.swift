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
                guard let item else { return Just(.empty).eraseToAnyPublisher() }
                if let error = item.error {
                    let event = MetricEvent(kind: .failure(error), time: item.currentTime())
                    item.metricLog.appendEvent(event)
                    return Just(.init(item: item, error: error)).eraseToAnyPublisher()
                }
                else {
                    return item.errorPublisher()
                        .handleEvents(receiveOutput: { error in
                            // swiftlint:disable:previous trailing_closure
                            let event = MetricEvent(kind: .failure(error), time: item.currentTime())
                            item.metricLog.appendEvent(event)
                        })
                        .map { .init(item: item, error: $0) }
                        .prepend(.init(item: item, error: nil))
                        .eraseToAnyPublisher()
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
