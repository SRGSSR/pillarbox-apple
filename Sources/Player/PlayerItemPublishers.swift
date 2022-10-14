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
                    ItemState.itemState(for: status, error: Self.localizeError(error))
                },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
                .map { _ in .ended }
        )
        .eraseToAnyPublisher()
    }

    func timeRangePublisher(configuration: PlayerConfiguration) -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.loadedTimeRanges),
            publisher(for: \.seekableTimeRanges),
            publisher(for: \.duration)
        )
        .compactMap { loadedTimeRanges, seekableTimeRanges, duration in
            guard let firstRange = seekableTimeRanges.first?.timeRangeValue,
                  let lastRange = seekableTimeRanges.last?.timeRangeValue else {
                return !loadedTimeRanges.isEmpty ? .zero : nil
            }

            let timeRange = CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
            if duration.isIndefinite && CMTimeCompare(timeRange.duration, configuration.dvrThreshold) == -1 {
                return CMTimeRange(start: timeRange.start, duration: .zero)
            }
            else {
                return timeRange
            }
        }
        .eraseToAnyPublisher()
    }

    // Errors returned through `AVAssetResourceLoader` do not apply correct error localization rules. Fix.
    private static func localizeError(_ error: Error?) -> Error? {
        guard let error = error as? NSError else { return nil }
        var userInfo = error.userInfo
        let descriptionKey = "NSDescription"
        userInfo[NSLocalizedDescriptionKey] = userInfo[descriptionKey]
        userInfo[descriptionKey] = nil
        return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
    }
}
