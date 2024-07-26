//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

final class CommandersActHeartbeat {
    private let delay: TimeInterval
    private let posInterval: TimeInterval
    private let uptimeInterval: TimeInterval

    private var properties: PlayerProperties?
    private var cancellable: AnyCancellable?

    init(delay: TimeInterval = 30, posInterval: TimeInterval = 30, uptimeInterval: TimeInterval = 60) {
        self.delay = delay
        self.posInterval = posInterval
        self.uptimeInterval = uptimeInterval
    }

    func update(with properties: PlayerProperties, labels: @escaping (PlayerProperties) -> [String: String]) {
        self.properties = properties

        if properties.playbackState == .playing {
            guard cancellable == nil else { return }
            cancellable = Self.eventPublisher(for: properties, delay: delay, posInterval: posInterval, uptimeInterval: uptimeInterval)
                .sink { [weak self] event in
                    self?.sendEvent(event, labels: labels)
                }
        }
        else {
            cancellable = nil
        }
    }

    private func sendEvent(_ event: Event, labels: @escaping (PlayerProperties) -> [String: String]) {
        guard let properties else { return }
        Analytics.shared.sendEvent(commandersAct: .init(
            name: event.rawValue,
            labels: labels(properties)
        ))
    }
}

private extension CommandersActHeartbeat {
    static func delayedPeriodicPublisher(delay: TimeInterval, interval: TimeInterval) -> AnyPublisher<Void, Never> {
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func eventPublisher(for event: Event, delay: TimeInterval, interval: TimeInterval) -> AnyPublisher<Event, Never> {
        delayedPeriodicPublisher(delay: delay, interval: interval)
            .map { _ in event }
            .eraseToAnyPublisher()
    }

    static func eventPublisher(
        for properties: PlayerProperties,
        delay: TimeInterval,
        posInterval: TimeInterval,
        uptimeInterval: TimeInterval
    ) -> AnyPublisher<Event, Never> {
        switch properties.streamType {
        case .onDemand:
            return eventPublisher(for: .pos, delay: delay, interval: posInterval)
        case .live, .dvr:
            return Publishers.Merge(
                eventPublisher(for: .pos, delay: delay, interval: posInterval),
                eventPublisher(for: .uptime, delay: delay, interval: uptimeInterval)
            )
            .eraseToAnyPublisher()
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}

private extension CommandersActHeartbeat {
    enum Event: String {
        case pos
        case uptime
    }
}
