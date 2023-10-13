//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine
import CoreMedia

final class TrackerMock<Metadata>: PlayerItemTracker where Metadata: Equatable {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State: Equatable {
        case initialized
        case enabled
        case disabled
        case updated(Metadata)
        case deinitialized
    }

    struct Configuration {
        let statePublisher: StatePublisher
    }

    private let configuration: Configuration
    private var cancellables = Set<AnyCancellable>()

    init(configuration: Configuration) {
        self.configuration = configuration
        configuration.statePublisher.send(.initialized)
    }

    func enable(for player: Player) {
        configuration.statePublisher.send(.enabled)
    }

    func updateMetadata(with metadata: Metadata) {
        configuration.statePublisher.send(.updated(metadata))
    }

    func updateProperties(with properties: PlayerProperties) {}

    func disable() {
        configuration.statePublisher.send(.disabled)
    }

    deinit {
        configuration.statePublisher.send(.deinitialized)
    }
}

extension TrackerMock {
    static func adapter<M>(statePublisher: StatePublisher, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        adapter(configuration: Configuration(statePublisher: statePublisher), mapper: mapper)
    }
}
