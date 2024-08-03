//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine

final class TrackerLifeCycleMock: PlayerItemTracker {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State: Equatable {
        case initialized
        case enabled
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

    func updateMetadata(to metadata: Void) {}

    func updateProperties(to properties: PlayerProperties) {}

    func updateMetricEvents(to events: [MetricEvent]) {}

    func enable(for player: AVPlayer) {
        configuration.statePublisher.send(.enabled)
    }

    func disable(with properties: PlayerProperties) {
        configuration.statePublisher.send(.disabled)
    }

    deinit {
        configuration.statePublisher.send(.deinitialized)
    }
}

extension TrackerLifeCycleMock {
    static func adapter(statePublisher: StatePublisher) -> TrackerAdapter<Void> {
        adapter(configuration: Configuration(statePublisher: statePublisher))
    }
}
