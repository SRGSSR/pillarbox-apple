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
                    notification.userInfo?[SeekKey.time] as? CMTime
                },
            notificationCenter.weakPublisher(for: .didSeek, object: self)
                .map { _ in nil }
        )
        .prepend(nil)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func propertiesPublisher(with playerItem: AVPlayerItem) -> AnyPublisher<PlayerProperties, Never> {
        Publishers.CombineLatest3(
            playerItem.propertiesPublisher(),
            playbackPropertiesPublisher(),
            seekTimePublisher()
        )
        .map { playerItemProperties, playbackProperties, seekTime in
            .init(
                coreProperties: .init(
                    itemProperties: playerItemProperties.itemProperties,
                    mediaSelectionProperties: playerItemProperties.mediaSelectionProperties,
                    playbackProperties: playbackProperties
                ),
                timeProperties: playerItemProperties.timeProperties,
                isEmpty: playerItemProperties.isEmpty,
                seekTime: seekTime
            )
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
