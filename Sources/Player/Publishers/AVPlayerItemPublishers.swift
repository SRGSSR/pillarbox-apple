//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaAccessibility
import PillarboxCore

extension AVPlayerItem {
    func propertiesPublisher() -> AnyPublisher<PlayerItemProperties, Never> {
        Publishers.CombineLatest8(
            statusPublisher()
                .lane("player_item_status"),
            publisher(for: \.presentationSize),
            mediaSelectionPropertiesPublisher()
                .lane("player_item_media_selection"),
            timePropertiesPublisher(),
            publisher(for: \.duration),
            minimumTimeOffsetFromLivePublisher(),
            metricsStatePublisher(),
            isStalledPublisher()
        )
        .map { [weak self] status, presentationSize, mediaSelectionProperties, timeProperties, duration, minimumTimeOffsetFromLive, metricsState, isStalled in
            let isKnown = (status != .unknown)
            return .init(
                itemProperties: .init(
                    item: self,
                    status: status,
                    duration: isKnown ? duration : .invalid,
                    minimumTimeOffsetFromLive: minimumTimeOffsetFromLive,
                    presentationSize: isKnown ? presentationSize : nil,
                    metricsState: metricsState,
                    isStalled: isStalled
                ),
                mediaSelectionProperties: mediaSelectionProperties,
                timeProperties: isKnown ? timeProperties : .empty
            )
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    private func timePropertiesPublisher() -> AnyPublisher<TimeProperties, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.loadedTimeRanges),
            publisher(for: \.seekableTimeRanges)
                .lane("player_item_seekable_time_ranges"),
            publisher(for: \.isPlaybackLikelyToKeepUp)
        )
        .map { .init(loadedTimeRanges: $0, seekableTimeRanges: $1, isPlaybackLikelyToKeepUp: $2) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    private func mediaSelectionPropertiesPublisher() -> AnyPublisher<MediaSelectionProperties, Never> {
        Publishers.CombineLatest3(
            asset.mediaSelectionGroupsPublisher(),
            mediaSelectionPublisher(),
            NotificationCenter.default.publisher(for: kMACaptionAppearanceSettingsChangedNotification as Notification.Name)
                .map { _ in }
                .prepend(())
        )
        .map { groups, selection, _ in
            MediaSelectionProperties(groups: groups, selection: selection)
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
    func statusPublisher() -> AnyPublisher<ItemStatus, Never> {
        Publishers.CombineLatest(
            publisher(for: \.status),
            isEndedPublisher()
        )
        .map { status, isEnded -> ItemStatus in
            switch status {
            case .readyToPlay:
                return isEnded ? .ended : .readyToPlay
            default:
                return .unknown
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    private func isEndedPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(endTimeNotificationPublisher(), timebaseUpdateNotificationPublisher())
            .prepend(false)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func endTimeNotificationPublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default.weakPublisher(for: AVPlayerItem.didPlayToEndTimeNotification, object: self)
            .map { _ in true }
            .eraseToAnyPublisher()
    }

    private func timebaseUpdateNotificationPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.timebase)
            .compactMap { $0 }
            .map { _ in false }
            .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func isStalledPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: AVPlayerItem.playbackStalledNotification, object: self)
                .map { _ in true },
            publisher(for: \.isPlaybackLikelyToKeepUp)
                .compactMap { $0 ? false : nil }
        )
        .prepend(false)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func errorPublisher() -> AnyPublisher<Error, Never> {
        Publishers.Merge(
            intrinsicErrorPublisher(),
            playbackErrorPublisher()
        )
        .eraseToAnyPublisher()
    }

    private func intrinsicErrorPublisher() -> AnyPublisher<Error, Never> {
        publisher(for: \.status)
            .filter { $0 == .failed }
            .weakCapture(self)
            .map { _, item in
                ItemError.error(for: item) ?? PlaybackError.unknown
            }
            .eraseToAnyPublisher()
    }

    private func playbackErrorPublisher() -> AnyPublisher<Error, Never> {
        NotificationCenter.default.weakPublisher(for: AVPlayerItem.failedToPlayToEndTimeNotification, object: self)
            .compactMap { $0.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error }
            .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func metricsStatePublisher() -> AnyPublisher<MetricsState, Never> {
        NotificationCenter.default.weakPublisher(for: AVPlayerItem.newAccessLogEntryNotification, object: self)
            .compactMap { $0.object as? AVPlayerItem }
            .prepend(self)
            .scan(.empty) { state, item in
                state.updated(with: item.accessLog(), at: item.currentTime())
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension AVPlayerItem {
    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge4(
            resourceLoadingMetricEventPublisher(),
            failureMetricEventPublisher(),
            warningMetricEventPublisher(),
            stallEventPublisher()
        )
        .eraseToAnyPublisher()
    }

    func resourceLoadingMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        publisher(for: \.isPlaybackLikelyToKeepUp)
            .first { $0 }
            .measureDateInterval()
            .weakCapture(self)
            .map { dateInterval, item in
                MetricEvent(
                    kind: .resourceLoading(dateInterval),
                    date: dateInterval.end,
                    time: item.currentTime()
                )
            }
            .eraseToAnyPublisher()
    }

    func failureMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        errorPublisher()
            .first()
            .weakCapture(self)
            .map { error, item in
                MetricEvent(
                    kind: .failure(error),
                    time: item.currentTime()
                )
            }
            .eraseToAnyPublisher()
    }

    func warningMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        NotificationCenter.default.weakPublisher(for: AVPlayerItem.newErrorLogEntryNotification, object: self)
            .compactMap { notification -> Error? in
                guard let lastErrorEvent = (notification.object as? AVPlayerItem)?.errorLog()?.events.last else { return nil }
                return NSError(
                    domain: lastErrorEvent.errorDomain,
                    code: lastErrorEvent.errorStatusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey: lastErrorEvent.errorComment
                    ].compactMapValues { $0 }
                )
            }
            .weakCapture(self)
            .map { error, item in
                MetricEvent(
                    kind: .warning(error),
                    time: item.currentTime()
                )
            }
            .eraseToAnyPublisher()
    }

    func stallEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        isStalledPublisher()
            .weakCapture(self)
            .map { isStalled, item in
                MetricEvent(
                    kind: isStalled ? .stall : .resumeAfterStall,
                    time: item.currentTime()
                )
            }
            .eraseToAnyPublisher()
    }
}
