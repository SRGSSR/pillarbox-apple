//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

final class TrackerUpdateMock<Metadata>: PlayerItemTracker where Metadata: Equatable {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State: Equatable {
        case enabled
        case disabled
        case updatedMetadata(Metadata)
        case updatedProperties(for: UUID)
    }

    struct Configuration {
        let statePublisher: StatePublisher
    }

    private let configuration: Configuration
    private var cancellables = Set<AnyCancellable>()

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func enable(for player: Player) {
        configuration.statePublisher.send(.enabled)
    }

    func updateMetadata(with metadata: Metadata) {
        configuration.statePublisher.send(.updatedMetadata(metadata))
    }

    func updateProperties(with properties: PlayerProperties) {
        configuration.statePublisher.send(.updatedProperties(for: properties.id))
    }

    func disable() {
        configuration.statePublisher.send(.disabled)
    }
}

extension TrackerUpdateMock {
    static func adapter<M>(statePublisher: StatePublisher, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        adapter(configuration: Configuration(statePublisher: statePublisher), mapper: mapper)
    }

    static func adapter(statePublisher: StatePublisher) -> TrackerAdapter<Never> {
        adapter(configuration: Configuration(statePublisher: statePublisher))
    }
}
