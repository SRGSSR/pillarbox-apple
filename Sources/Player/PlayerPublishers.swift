//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

// TODO: Other ideas for publishers
//        - Boundary time publisher
//        - Asset property publisher (can register to one or several properties and have them published; implemented
//          internally with modern async API). Might be useful as signal for the Pulse publisher.

extension AVPlayer {
    func playbackStatePublisher() -> AnyPublisher<PlaybackState, Never> {
        Publishers.CombineLatest(
            itemStatePublisher(),
            ratePublisher()
        )
        .map { PlaybackState.state(for: $0, rate: $1) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func ratePublisher() -> AnyPublisher<Float, Never> {
        publisher(for: \.rate)
            .eraseToAnyPublisher()
    }

    func itemDurationPublisher() -> AnyPublisher<CMTime, Never> {
        Just(.zero).eraseToAnyPublisher()
    }

    func timeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        Just(.zero).eraseToAnyPublisher()
    }

    func currentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.Merge(
            itemStatePublisher()
                .filter { $0 == .readyToPlay }
                .map { _ in .zero },
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue)
        )
        .eraseToAnyPublisher()
    }

    func seekTargetTimePublisher() -> AnyPublisher<CMTime?, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: .willSeek, object: self)
                .map { $0.userInfo?[DequeuePlayer.SeekInfoKey.targetTime] as? CMTime },
            NotificationCenter.default.weakPublisher(for: .didSeek, object: self)
                .map { _ in nil }
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }

    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.itemStatePublisher() }
            .switchToLatest()
            .prepend(ItemState.itemState(for: currentItem))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func pulsePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<Pulse?, Never> {
        // TODO: Maybe better criterium than item state (asset duration? Maybe more resilient for AirPlay). Extract
        //       timeRange by KVObserving loaded and seekable time ranges.
        Publishers.CombineLatest(
            currentTimePublisher(interval: interval, queue: queue),
            itemDurationPublisher()
        )
        .compactMap { [weak self] time, itemDuration in
            guard let self, let timeRange = Time.timeRange(for: self.currentItem) else { return nil }
            return Pulse(time: time, timeRange: timeRange, itemDuration: itemDuration)
        }
        .removeDuplicates(by: Pulse.close(within: CMTimeGetSeconds(interval) / 2))
        .eraseToAnyPublisher()
    }

    func playbackPropertiesPublisher(interval: CMTime) -> AnyPublisher<PlaybackProperties, Never> {
        Publishers.CombineLatest(
            pulsePublisher(interval: interval, queue: DispatchQueue(label: "ch.srgssr.pillarbox.player")),
            seekTargetTimePublisher()
        )
        .map { PlaybackProperties(pulse: $0, targetTime: $1) }
        .removeDuplicates(by: PlaybackProperties.close(within: CMTimeGetSeconds(interval) / 2))
        .eraseToAnyPublisher()
    }
}
