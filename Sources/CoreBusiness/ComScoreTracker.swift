//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

/// Tracker for comScore stream tracking.
public final class ComScoreTracker: PlayerItemTracker {
    private let id = UUID()

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        print("--> enable comScore \(id)")
    }

    public func update(metadata: [String: String]) {
        print("--> update comScore metadata: \(metadata)")
    }

    public func disable() {
        print("--> disable comScore \(id)")
    }
}
