//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

/// Tracker for CommandersAct stream tracking.
public final class CommandersActTracker: PlayerItemTracker {
    private let id = UUID()

    public init() {}

    public func enable(for player: Player) {
        print("--> enable CommandersAct \(id)")
    }

    public func update(metadata: [String: String]) {
        print("--> update CommandersAct metadata: \(metadata)")
    }

    public func disable() {
        print("--> disable CommandersAct \(id)")
    }
}
