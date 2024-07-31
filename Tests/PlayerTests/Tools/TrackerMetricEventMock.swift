//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine

final class TrackerMetricEventMock: PlayerItemTracker {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State: Equatable {
        case initialized
        case enabled
        case metricEvent
        case disabled
        case deinitialized
    }

    struct Configuration {
        let statePublisher: StatePublisher
    }

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
        configuration.statePublisher.send(.initialized)
    }

    func updateMetadata(with metadata: Void) {}

    func updateProperties(with properties: PlayerProperties) {}

    func enable(for player: AVPlayer) {
        configuration.statePublisher.send(.enabled)
    }

    func receiveMetricEvent(_ event: MetricEvent) {
        configuration.statePublisher.send(.metricEvent)
    }

    func disable(with properties: PlayerProperties) {
        configuration.statePublisher.send(.disabled)
    }

    deinit {
        configuration.statePublisher.send(.deinitialized)
    }
}

extension TrackerMetricEventMock {
    static func adapter(statePublisher: StatePublisher) -> TrackerAdapter<Void> {
        adapter(configuration: Configuration(statePublisher: statePublisher))
    }
}
