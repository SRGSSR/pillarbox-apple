//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVPlayerItem {
    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        Publishers.Merge(
            publisher(for: \.status)
                .weakCapture(self, at: \.error)
                .map { status, error in
                    ItemState.itemState(for: status, error: error?.localized())
                },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
                .map { _ in .ended }
        )
        .eraseToAnyPublisher()
    }

    func timeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.loadedTimeRanges),
            publisher(for: \.seekableTimeRanges),
            publisher(for: \.duration)
        )
        .compactMap { loadedTimeRanges, seekableTimeRanges, _ in
            guard let firstRange = seekableTimeRanges.first?.timeRangeValue,
                  let lastRange = seekableTimeRanges.last?.timeRangeValue else {
                return !loadedTimeRanges.isEmpty ? .zero : nil
            }
            return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
        }
        .eraseToAnyPublisher()
    }
}
