//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine

final class NonConfigurableTrackerMock: ObservableObject, PlayerItemTracker {
    enum State: Equatable {
        case initialized
        case enabled
        case disabled
        case updated(String)
        case deinitialized
    }

    static var state = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(configuration: Void, metadataPublisher: AnyPublisher<String, Never>) {
        Self.state.send(.initialized)

        metadataPublisher
            .sink { metadata in
                Self.state.send(.updated(metadata))
            }
        .store(in: &cancellables)
    }

    func enable(for player: Player) {
        Self.state.send(.enabled)
    }

    func update(metadata: String) {
        Self.state.send(.updated(metadata))
    }

    func disable() {
        Self.state.send(.disabled)
    }

    deinit {
        Self.state.send(.deinitialized)
        cancellables = []
    }
}
