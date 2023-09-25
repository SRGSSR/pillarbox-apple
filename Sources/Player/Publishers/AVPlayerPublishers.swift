//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import TimelaneCombine

// TODO: Remove once migration done

extension AVPlayer {
    func currentItemTimeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        publisher(for: \.currentItem)
            .map { item in
                guard let item else { return Just(CMTimeRange.invalid).eraseToAnyPublisher() }
                return item.timeRangePublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func currentItemBufferPublisher() -> AnyPublisher<Float, Never> {
        publisher(for: \.currentItem)
            .map { item -> AnyPublisher<Float, Never> in
                guard let item else { return Just(0).eraseToAnyPublisher() }
                return Publishers.CombineLatest(
                    item.loadedTimeRangePublisher(),
                    item.durationPublisher()
                )
                .map { loadedTimeRange, duration in
                    guard loadedTimeRange.end.isNumeric, duration.isNumeric, duration != .zero else { return 0 }
                    return Float(loadedTimeRange.end.seconds / duration.seconds)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
