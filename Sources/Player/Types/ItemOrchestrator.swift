//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxCore

private enum TriggerId: Hashable {
    case load(UUID)
    case reset(UUID)
}

struct ItemOrchestrator {
    private static let trigger = Trigger()

    static func resetSignal(for id: UUID) -> Trigger.Signal {
        trigger.signal(activatedBy: TriggerId.reset(id))
    }

    static func loadSignal(for id: UUID) -> Trigger.Signal {
        trigger.signal(activatedBy: TriggerId.load(id))
    }

    static func load(for id: UUID) {
        trigger.activate(for: TriggerId.load(id))
    }

    static func reload(for id: UUID) {
        trigger.activate(for: TriggerId.reset(id))
        trigger.activate(for: TriggerId.load(id))
    }
}
