//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension Publishers {
    struct PeriodicTimePublisher: Publisher {
        typealias Output = CMTime
        typealias Failure = Never

        let player: AVPlayer
        let interval: CMTime
        let queue: DispatchQueue

        init(player: AVPlayer, interval: CMTime, queue: DispatchQueue = .main) {
            self.interval = interval
            self.queue = queue
            self.player = player
        }

        func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CMTime == S.Input {
            let subscription = Subscription(subscriber: subscriber, player: player, interval: interval, queue: queue)
            subscriber.receive(subscription: subscription)
        }
    }
}

private extension Publishers.PeriodicTimePublisher {
    final actor Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let player: AVPlayer
        private let interval: CMTime
        private let queue: DispatchQueue

        private var demand = Subscribers.Demand.none
        private var timeObserver: Any?

        init(subscriber: S, player: AVPlayer, interval: CMTime, queue: DispatchQueue) {
            self.subscriber = subscriber
            self.player = player
            self.interval = interval
            self.queue = queue
        }

        private func processDemand(_ demand: Subscribers.Demand) {
            self.demand += demand
            guard timeObserver == nil else { return }
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) { [weak self] time in
                self?.processTime(time)
            }
        }

        private func processCancellation() {
            if let timeObserver {
                player.removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            subscriber = nil
        }

        private func send(_ time: CMTime) {
            guard let subscriber = self.subscriber, self.demand > .none else { return }
            self.demand -= 1
            self.demand += subscriber.receive(time)
        }

        private nonisolated func processTime(_ time: CMTime) {
            Task {
                await send(time)
            }
        }

        nonisolated func request(_ demand: Subscribers.Demand) {
            Task {
                await processDemand(demand)
            }
        }

        nonisolated func cancel() {
            Task {
                await processCancellation()
            }
        }
    }
}

extension Player {
    static func propertiesPublisher(for player: Player) -> AnyPublisher<Properties, Never> {
        Publishers.CombineLatest4(
            itemStatePublisher(for: player),
            ratePublisher(for: player),
            playbackPublisher(for: player, queue: DispatchQueue(label: "ch.srgssr.pillarbox.player")),
            targetTimePublisher(for: player)
        )
        .map { Properties(
            itemState: $0,
            rate: $1,
            playback: $2,
            targetTime: $3
        ) }
        .eraseToAnyPublisher()
    }

    private static func itemStatePublisher(for player: Player) -> AnyPublisher<ItemState, Never> {
        return player.systemPlayer.publisher(for: \.currentItem)
            .map { item -> AnyPublisher<ItemState, Never> in
                guard let item else {
                    return Just(.unknown)
                        .eraseToAnyPublisher()
                }
                return statePublisher(for: item)
            }
            .switchToLatest()
            .prepend(.unknown)
            .eraseToAnyPublisher()
    }

    private static func ratePublisher(for player: Player) -> AnyPublisher<Float, Never> {
        return player.systemPlayer.publisher(for: \.rate)
            .prepend(player.systemPlayer.rate)
            .eraseToAnyPublisher()
    }

    private static func playbackPublisher(for player: Player, queue: DispatchQueue) -> AnyPublisher<Properties.Playback, Never> {
        player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 1), queue: queue)
            .map { [weak player] time in
                return Properties.Playback(
                    time: time,
                    timeRange: Time.timeRange(for: player?.systemPlayer.currentItem)
                )
            }
            .eraseToAnyPublisher()
    }

    private static func targetTimePublisher(for player: Player) -> AnyPublisher<CMTime?, Never> {
        return Publishers.Merge(
            NotificationCenter.default.publisher(for: .willSeek, object: player)
                .map { $0.userInfo?[SystemPlayer.SeekInfoKey.targetTime] as? CMTime },
            NotificationCenter.default.publisher(for: .didSeek, object: player)
                .map { _ in nil }
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }

    private static func statePublisher(for item: AVPlayerItem) -> AnyPublisher<ItemState, Never> {
        Publishers.Merge(
            item.publisher(for: \.status)
                .map { status in
                    switch status {
                    case .readyToPlay:
                        return .readyToPlay
                    case .failed:
                        return .failed(error: item.error ?? PlaybackError.unknown)
                    default:
                        return .unknown
                    }
                },
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
                .map { _ in .ended }
        )
        .eraseToAnyPublisher()
    }

    public func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(player: systemPlayer, interval: interval, queue: queue)
            .removeDuplicates(by: Time.close(within: 0.1))
            .eraseToAnyPublisher()
    }
}
