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
            seekMarkPublisher(),
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue)
        )
        .map { $0?.time() ?? $1.time }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func seekMarkPublisher() -> AnyPublisher<Mark?, Never> {
        let notificationCenter = Self.notificationCenter
        return Publishers.Merge(
            notificationCenter.weakPublisher(for: .willSeek, object: self)
                .map { notification in
                    notification.userInfo?[SeekNotificationKey.mark] as? Mark
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
            seekMarkPublisher(),
            mediaSelectionCriteriaPublisher()
        )
        .map { playerItemProperties, playbackProperties, seekMark, mediaSelectionCriteria in
            PlayerProperties(
                coreProperties: .init(
                    itemProperties: playerItemProperties.itemProperties,
                    mediaSelectionProperties: playerItemProperties.mediaSelectionProperties,
                    playbackProperties: playbackProperties,
                    mediaSelectionCriteria: mediaSelectionCriteria
                ),
                timeProperties: playerItemProperties.timeProperties,
                isEmpty: playerItemProperties.isEmpty,
                seekMark: seekMark
            )
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func mediaSelectionCriteriaPublisher() -> AnyPublisher<[AVMediaCharacteristic: AVPlayerMediaSelectionCriteria], Never> {
        Self.notificationCenter.weakPublisher(for: .didUpdateMediaSelectionCriteria, object: self)
            .map { notification in
                // swiftlint:disable:next line_length
                notification.userInfo?[MediaSelectionCriteriaUpdateNotificationKey.mediaSelection] as? [AVMediaCharacteristic: AVPlayerMediaSelectionCriteria?] ?? [:]
            }
            .prepend(mediaSelectionCriteria)
            .map { $0.compactMapValues(\.self) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
