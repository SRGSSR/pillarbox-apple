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
        case unknown
        case enabled
        case disabled
    }

    @Published var state: State = .unknown
}

extension TrackerMock: PlayerItemTracker {
    func enable(for player: Player) {
        state = .enabled
    }

    func disable() {
        state = .disabled
    }
}
