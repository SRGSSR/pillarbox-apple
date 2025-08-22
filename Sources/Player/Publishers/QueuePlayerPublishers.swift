//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension QueuePlayer {
    /// Publishes the current time, smoothing out emitted values during seeks.
    func smoothCurrentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            seekTimePublisher(),
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue)
        )
        .map { $0 ?? $1 }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func seekTimePublisher() -> AnyPublisher<CMTime?, Never> {
        let notificationCenter = Self.notificationCenter
        return Publishers.Merge(
            notificationCenter.weakPublisher(for: .willSeek, object: self)
                .map { notification in
                    notification.userInfo?[SeekNotificationKey.time] as? CMTime
                },
            notificationCenter.weakPublisher(for: .didSeek, object: self)
                .map { _ in nil }
        )
        .prepend(nil)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func propertiesPublisher(
        withPlayerItemPropertiesPublisher playerItemPropertiesPublisher: AnyPublisher<PlayerItemProperties, Never>
    ) -> AnyPublisher<PlayerProperties, Never> {
        Publishers.CombineLatest4(
            playerItemPropertiesPublisher,
            playbackPropertiesPublisher(),
            seekTimePublisher(),
            mediaSelectionCriteriaPublisher()
        )
        .map { playerItemProperties, playbackProperties, seekTime, mediaSelectionCriteria in
            PlayerProperties(
                coreProperties: .init(
                    itemProperties: playerItemProperties.itemProperties,
                    mediaSelectionProperties: playerItemProperties.mediaSelectionProperties,
                    playbackProperties: playbackProperties,
                    mediaSelectionCriteria: mediaSelectionCriteria
                ),
                timeProperties: playerItemProperties.timeProperties,
                isEmpty: playerItemProperties.isEmpty,
                seekTime: seekTime
            )
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func mediaSelectionCriteriaPublisher() -> AnyPublisher<[AVMediaCharacteristic: AVPlayerMediaSelectionCriteria?], Never> {
        Self.notificationCenter.weakPublisher(for: .didUpdateMediaSelectionCriteria, object: self)
            .map { notification in
                notification.userInfo?[MediaSelectionCriteriaUpdateNotificationKey.mediaSelection] as? [AVMediaCharacteristic: AVPlayerMediaSelectionCriteria?] ?? [:]
            }
            .prepend(mediaSelectionCriteria)
            .eraseToAnyPublisher()
    }
}
