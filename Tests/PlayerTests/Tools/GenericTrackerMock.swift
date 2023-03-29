//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine

final class GenericTrackerMock<Parameter, Metadata>: PlayerItemTracker {
    enum State {
        case initialized(Parameter)
        case enabled
        case disabled
        case updated(Metadata)
        case deinitialized
    }

    struct Configuration {
        // swiftlint:disable:next private_subject
        let statePublisher: PassthroughSubject<State, Never>
        let parameter: Parameter
    }

    private let configuration: Configuration
    private var cancellables = Set<AnyCancellable>()

    init(configuration: Configuration, metadataPublisher: AnyPublisher<Metadata, Never>) {
        self.configuration = configuration

        configuration.statePublisher.send(.initialized(configuration.parameter))
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
