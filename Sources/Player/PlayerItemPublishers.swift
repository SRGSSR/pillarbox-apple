//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core

extension AVPlayerItem {
    private static func mediaType(for item: AVPlayerItem) -> MediaType {
        guard item.status == .readyToPlay else { return .unknown }
        return item.presentationSize == .zero ? .audio : .video
    }

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

    func nowPlayingInfoPropertiesPublisher() -> AnyPublisher<NowPlaying.Properties, Never> {
        Publishers.CombineLatest3(
            timeRangePublisher(),
            durationPublisher(),
            bufferingPublisher()
        )
        .map { NowPlaying.Properties(timeRange: $0, itemDuration: $1, isBuffering: $2) }
        .eraseToAnyPublisher()
    }

    func mediaTypePublisher() -> AnyPublisher<MediaType, Never> {
        publisher(for: \.status)
            .weakCapture(self)
            .map { status, item -> AnyPublisher<MediaType, Never> in
                guard status == .readyToPlay else {
                    return Just(.unknown).eraseToAnyPublisher()
                }
                return item.publisher(for: \.presentationSize)
                    .map { size in
                        size == .zero ? .audio : .video
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            // Mitigate incorrect media types, most notably returned when disconnecting AirPlay while the media type
            // is still unknown. This trick works in all cases, whether AirPlay is not enabled, enabled before
            // playback or during playback. We therefore do not have to check that a route is enabled here.
            .dropFirst()
            .prepend(Self.mediaType(for: self))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
