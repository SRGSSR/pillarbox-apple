//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine

final class PlayerItemTrackerMock: PlayerItemTracker {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State: Equatable {
        case initialized
        case enabled
        case metricEvents
        case disabled
        case deinitialized
    }

    struct Configuration {
        let statePublisher: StatePublisher
        let sessionIdentifier: String?

        init(statePublisher: StatePublisher = .init(), sessionIdentifier: String? = nil) {
            self.statePublisher = statePublisher
            self.sessionIdentifier = sessionIdentifier
        }
    }

    private let configuration: Configuration

    var sessionIdentifier: String? {
        configuration.sessionIdentifier
    }

    init(configuration: Configuration) {
        self.configuration = configuration
        configuration.statePublisher.send(.initialized)
    }

    func updateMetadata(to metadata: Void) {}

    func updateProperties(to properties: TrackerProperties) {}

    func updateMetricEvents(to events: [MetricEvent]) {
        guard !events.isEmpty else { return }
        configuration.statePublisher.send(.metricEvents)
    }

    func enable(for player: AVPlayer) {
        configuration.statePublisher.send(.enabled)
    }

    func disable(with properties: TrackerProperties) {
        configuration.statePublisher.send(.disabled)
    }

    deinit {
        configuration.statePublisher.send(.deinitialized)
    }
}

extension PlayerItemTrackerMock {
    static func adapter(statePublisher: StatePublisher, behavior: TrackingBehavior = .optional) -> TrackerAdapter<Void> {
        adapter(configuration: Configuration(statePublisher: statePublisher), behavior: behavior)
    }
}
