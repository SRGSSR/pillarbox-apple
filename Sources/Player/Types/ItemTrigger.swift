//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCore

private enum TriggerId: Hashable {
    case load
    case reset
}

struct ItemTrigger {
    private let trigger = Trigger()

    func load() {
        trigger.activate(for: TriggerId.load)
    }

    func reload() {
        trigger.activate(for: TriggerId.reset)
        trigger.activate(for: TriggerId.load)
    }

    func resetSignal() -> Trigger.Signal {
        trigger.signal(activatedBy: TriggerId.reset)
    }

    func loadSignal() -> Trigger.Signal {
        trigger.signal(activatedBy: TriggerId.load)
    }
}
