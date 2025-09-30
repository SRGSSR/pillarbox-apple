//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine

final class TrackerUpdateMock<Metadata>: PlayerItemTracker where Metadata: Equatable {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State: Equatable {
        case enabled
        case disabled
        case updatedMetadata(Metadata)
        case updatedProperties
    }

    struct Configuration {
        let statePublisher: StatePublisher
    }

    private let configuration: Configuration

    init(configuration: Configuration, queue: DispatchQueue) {
        self.configuration = configuration
    }

    func enable(for player: AVPlayer) {
        configuration.statePublisher.send(.enabled)
    }

    func updateMetadata(to metadata: Metadata) {
        configuration.statePublisher.send(.updatedMetadata(metadata))
    }

    func updateProperties(to properties: TrackerProperties) {
        configuration.statePublisher.send(.updatedProperties)
    }

    func updateMetricEvents(to events: [MetricEvent]) {}

    func disable(with properties: TrackerProperties) {
        configuration.statePublisher.send(.disabled)
    }
}

extension TrackerUpdateMock {
    static func adapter<M>(statePublisher: StatePublisher, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> {
        adapter(configuration: Configuration(statePublisher: statePublisher), mapper: mapper)
    }
}
