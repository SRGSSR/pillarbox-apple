//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine
import Foundation

class TrackerMock: ObservableObject {
    enum State {
        case initialized
        case enabled
        case disabled
        case deinitialized
    }

    @Published var state: State = .initialized

    deinit {
        state = .deinitialized
    }
}

extension TrackerMock: PlayerItemTracker {
    func enable(for player: Player) {
        state = .enabled
    }

    func disable() {
        state = .disabled
    }
}
