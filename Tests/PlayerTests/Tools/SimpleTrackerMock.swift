//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine

final class SimpleTrackerMock: ObservableObject, PlayerItemTracker {
    enum State: Equatable {
        case initialized
        case enabled
        case disabled
        case deinitialized
    }

    static var state = PassthroughSubject<State, Never>()

    init(configuration: Void, metadataPublisher: AnyPublisher<Void, Never>) {
        Self.state.send(.initialized)
    }

    func enable(for player: Player) {
        Self.state.send(.enabled)
    }

    func disable() {
        Self.state.send(.disabled)
    }

    deinit {
        Self.state.send(.deinitialized)
    }
}
