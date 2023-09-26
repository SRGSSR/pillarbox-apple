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
    func propertiesPublisher() -> AnyPublisher<AVPlayerItemProperties, Never> {
        Publishers.CombineLatest6(
            statePublisher(),
            publisher(for: \.isPlaybackLikelyToKeepUp),
            publisher(for: \.presentationSize),
            mediaSelectionContextPublisher(),
            publisher(for: \.duration),
            minimumTimeOffsetFromLivePublisher()
        )
        .map { state, isPlaybackLikelyToKeepUp, presentationSize, mediaSelectionContext, duration, minimumTimeOffsetFromLive in
            let isKnown = (state != .unknown)
            return AVPlayerItemProperties(
                state: state,
                isPlaybackLikelyToKeepUp: isPlaybackLikelyToKeepUp,
                duration: isKnown ? duration : .invalid,
                minimumTimeOffsetFromLive: minimumTimeOffsetFromLive,
                presentationSize: isKnown ? presentationSize : nil,
                mediaSelectionContext: mediaSelectionContext
            )
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func statePublisher() -> AnyPublisher<ItemState, Never> {
        Publishers.Merge(
            publisher(for: \.status)
                .map { status in
                    switch status {
                    case .readyToPlay:
                        return .readyToPlay
                    default:
                        return .unknown
                    }
                },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
                .map { _ in .ended }
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

   private func mediaSelectionContextPublisher() -> AnyPublisher<MediaSelectionContext, Never> {
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
        .removeDuplicates()
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

    private func minimumTimeOffsetFromLivePublisher() -> AnyPublisher<CMTime, Never> {
        asset.propertyPublisher(.minimumTimeOffsetFromLive)
            .replaceError(with: .invalid)
            .prepend(.invalid)
            .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func errorPublisher() -> AnyPublisher<Error?, Never> {
        Publishers.Merge(
            intrinsicErrorPublisher(),
            playbackErrorPublisher()
        )
        .map { Optional($0) }
        .prepend(nil)
        .eraseToAnyPublisher()
    }

    private func intrinsicErrorPublisher() -> AnyPublisher<Error, Never> {
        publisher(for: \.status)
            .filter { $0 == .failed }
            .weakCapture(self)
            .map { _, item in
                ItemError.intrinsicError(for: item)
            }
            .eraseToAnyPublisher()
    }

    private func playbackErrorPublisher() -> AnyPublisher<Error, Never> {
        NotificationCenter.default.weakPublisher(for: .AVPlayerItemFailedToPlayToEndTime, object: self)
            .compactMap { notification in
                guard let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else {
                    return nil
                }
                return ItemError.localizedError(from: error)
            }
            .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func timePropertiesPublisher() -> AnyPublisher<TimeProperties, Never> {
        statePublisher()
            .map { [weak self] state in
                guard let self, state != .unknown else { return Just(TimeProperties.empty).eraseToAnyPublisher() }
                return Publishers.CombineLatest(
                    publisher(for: \.loadedTimeRanges),
                    publisher(for: \.seekableTimeRanges)
                )
                .map { loadedTimeRanges, seekableTimeRanges in
                    .init(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
