//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVPlayerItem {
    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        Publishers.Merge3(
            publisher(for: \.status)
                .weakCapture(self)
                .map { ItemState.itemState(for: $0.1) },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
                .map { _ in .ended },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemFailedToPlayToEndTime, object: self)
                .compactMap { ItemState.itemState(for: $0) }
        )
        .eraseToAnyPublisher()
    }

    func timeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest(
            publisher(for: \.loadedTimeRanges),
            publisher(for: \.seekableTimeRanges)
        )
        .compactMap { loadedTimeRanges, seekableTimeRanges in
            guard let firstRange = seekableTimeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
                  let lastRange = seekableTimeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
                return !loadedTimeRanges.isEmpty ? .zero : nil
            }
            return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
        }
        .eraseToAnyPublisher()
    }
}
