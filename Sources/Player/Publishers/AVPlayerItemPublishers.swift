//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import MediaAccessibility

extension AVPlayerItem {
    func contextPublisher() -> AnyPublisher<AVPlayerItemContext, Never> {
        Publishers.CombineLatest(
            statePublisher(),
            isPlaybackLikelyToKeepUpPublisher()
        )
        .map { [weak self] state, isPlaybackLikelyToKeepUp -> AnyPublisher<AVPlayerItemContext, Never> in
            guard let self, state == .readyToPlay else {
                return Just(.empty(state: state, isPlaybackLikelyToKeepUp: isPlaybackLikelyToKeepUp)).eraseToAnyPublisher()
            }
            return Publishers.CombineLatest(
                presentationSizePublisher(),
                mediaSelectionContextPublisher()
            )
            .map { presentationSize, mediaSelectionContext in
                AVPlayerItemContext(
                    state: state,
                    isPlaybackLikelyToKeepUp: isPlaybackLikelyToKeepUp,
                    presentationSize: presentationSize,
                    mediaSelectionContext: mediaSelectionContext
                )
            }
            .eraseToAnyPublisher()
        }
        .switchToLatest()
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func statePublisher() -> AnyPublisher<ItemState, Never> {
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

    func isPlaybackLikelyToKeepUpPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.isPlaybackLikelyToKeepUp)
            .eraseToAnyPublisher()
    }

    func presentationSizePublisher() -> AnyPublisher<CGSize, Never> {
        publisher(for: \.presentationSize)
            .eraseToAnyPublisher()
    }

    func mediaSelectionContextPublisher() -> AnyPublisher<MediaSelectionContext, Never> {
        Publishers.CombineLatest3(
            asset.mediaSelectionGroupsPublisher(),
            mediaSelectionPublisher(),
            NotificationCenter.default.publisher(for: kMACaptionAppearanceSettingsChangedNotification as Notification.Name)
                .map { _ in }
                .prepend(())
        )
        .map { groups, selection, _ in
            MediaSelectionContext(groups: groups, selection: selection)
        }
        .prepend(.empty)
        .eraseToAnyPublisher()
    }

    private func mediaSelectionPublisher() -> AnyPublisher<AVMediaSelection, Never> {
        publisher(for: \.status)
            .weakCapture(self)
            .compactMap { status, item -> AnyPublisher<AVMediaSelection, Never>? in
                guard status == .readyToPlay else { return nil }
                return item.publisher(for: \.currentMediaSelection)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .prepend(currentMediaSelection)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func timeContextPublisher() -> AnyPublisher<TimeContext, Never> {
        statePublisher()
            .map { [weak self] state in
                guard let self, state == .readyToPlay else { return Just(TimeContext.empty).eraseToAnyPublisher() }
                return Publishers.CombineLatest4(
                    durationPublisher(),
                    minimumTimeOffsetFromLivePublisher(),
                    publisher(for: \.loadedTimeRanges),
                    publisher(for: \.seekableTimeRanges)
                )
                .map { duration, minimumTimeOffsetFromLive, loadedTimeRanges, seekableTimeRanges in
                    .init(duration: duration, minimumTimeOffsetFromLive: minimumTimeOffsetFromLive, loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func durationPublisher() -> AnyPublisher<CMTime, Never> {
        publisher(for: \.duration)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func minimumTimeOffsetFromLivePublisher() -> AnyPublisher<CMTime, Never> {
        asset.propertyPublisher(.minimumTimeOffsetFromLive)
            .replaceError(with: .invalid)
            .prepend(.invalid)
            .eraseToAnyPublisher()
    }
}

// TODO: Remove once migration done

extension AVPlayerItem {
    func timeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.status),
            publisher(for: \.loadedTimeRanges),
            publisher(for: \.seekableTimeRanges)
        )
        .map { status, loadedTimeRanges, seekableTimeRanges in
            guard status == .readyToPlay else { return .invalid }
            return TimeContext.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
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
            statePublisher()
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

    func presentationSizePublisherLegacy() -> AnyPublisher<CGSize?, Never> {
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
