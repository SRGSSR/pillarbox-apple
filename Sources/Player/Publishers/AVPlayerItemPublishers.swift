//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core

extension AVPlayerItem {
    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        Publishers.Merge3(
            publisher(for: \.status)
                .weakCapture(self)
                .map { ItemState(for: $0.1) },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
                .map { _ in .ended },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemFailedToPlayToEndTime, object: self)
                .compactMap { ItemState(for: $0) }
        )
        .eraseToAnyPublisher()
    }

    func timeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.status),
            publisher(for: \.loadedTimeRanges),
            publisher(for: \.seekableTimeRanges)
        )
        .map { status, loadedTimeRanges, seekableTimeRanges in
            guard status == .readyToPlay else { return .invalid }
            return Self.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func loadedTimeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest(
            publisher(for: \.status),
            publisher(for: \.loadedTimeRanges)
        )
        .map { status, loadedTimeRanges in
            guard status == .readyToPlay else { return .invalid }
            let start = loadedTimeRanges.first?.timeRangeValue.start ?? .zero
            let end = loadedTimeRanges.last?.timeRangeValue.end ?? .zero
            return CMTimeRangeFromTimeToTime(start: start, end: end)
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func durationPublisher() -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            publisher(for: \.status),
            publisher(for: \.duration)
        )
        .map { status, duration in
            status == .readyToPlay ? duration : .invalid
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func streamTypePublisher() -> AnyPublisher<StreamType, Never> {
        Publishers.CombineLatest(
            timeRangePublisher(),
            durationPublisher()
        )
        .map { timeRange, duration in
            StreamType(for: timeRange, itemDuration: duration)
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func bufferingPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(
            publisher(for: \.isPlaybackLikelyToKeepUp),
            itemStatePublisher()
        )
        .map { isPlaybackLikelyToKeepUp, itemState in
            switch itemState {
            case .failed:
                return false
            default:
                return !isPlaybackLikelyToKeepUp
            }
        }
        .prepend(false)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func mediaSelectorPublisher() -> AnyPublisher<MediaSelector, Never> {
        Publishers.CombineLatest(
            asset.mediaSelectionGroupsPublisher(),
            publisher(for: \.currentMediaSelection)
        )
        .map { MediaSelector(groups: $0, selection: $1) }
        .eraseToAnyPublisher()
    }

    func nowPlayingInfoPropertiesPublisher() -> AnyPublisher<NowPlaying.Properties, Never> {
        Publishers.CombineLatest3(
            timeRangePublisher(),
            durationPublisher(),
            bufferingPublisher()
        )
        .map { NowPlaying.Properties(timeRange: $0, itemDuration: $1, isBuffering: $2) }
        .eraseToAnyPublisher()
    }

    func presentationSizePublisher() -> AnyPublisher<CGSize?, Never> {
        publisher(for: \.status)
            .weakCapture(self)
            .map { status, item -> AnyPublisher<CGSize?, Never> in
                guard status == .readyToPlay else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return item.publisher(for: \.presentationSize)
                    .map { Optional($0) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
