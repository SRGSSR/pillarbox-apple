//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine

final class EmptyTrackerMock: PlayerItemTracker {
    typealias StatePublisher = PassthroughSubject<State, Never>

    enum State {
        case initialized
        case enabled
        case disabled
        case updated
        case deinitialized
    }

    struct Configuration {
        let statePublisher: StatePublisher
    }

    private let configuration: Configuration
    private var cancellables = Set<AnyCancellable>()

    init(configuration: Configuration, metadataPublisher: AnyPublisher<Void, Never>) {
        self.configuration = configuration
        configuration.statePublisher.send(.initialized)
        metadataPublisher.sink { _ in
            configuration.statePublisher.send(.updated)
        }
        .store(in: &cancellables)
    }

    func enable(for player: Player) {
        configuration.statePublisher.send(.enabled)
    }

    func disable() {
        configuration.statePublisher.send(.disabled)
    }

    deinit {
        configuration.statePublisher.send(.deinitialized)
    }
}

final class GenericTrackerMock<Metadata: Equatable>: PlayerItemTracker {
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

    init(configuration: Configuration, metadataPublisher: AnyPublisher<Metadata, Never>) {
        self.configuration = configuration
        configuration.statePublisher.send(.initialized)
        metadataPublisher.sink { metadata in
            configuration.statePublisher.send(.updated(metadata))
        }
        .store(in: &cancellables)
    }

    func enable(for player: Player) {
        configuration.statePublisher.send(.enabled)
    }

    func disable() {
        configuration.statePublisher.send(.disabled)
    }

    deinit {
        configuration.statePublisher.send(.deinitialized)
    }
}

extension GenericTrackerMock {
    static func adapter<M>(statePublisher: StatePublisher, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        adapter(configuration: Configuration(statePublisher: statePublisher), mapper: mapper)
    }
}

extension EmptyTrackerMock {
    static func adapter(statePublisher: StatePublisher) -> TrackerAdapter<Never> {
        adapter(configuration: Configuration(statePublisher: statePublisher))
    }
}
