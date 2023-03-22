//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

struct DemoTracker: PlayerItemTracker {
    struct Metadata {
        let title: String
    }

    private let id = UUID()

    func enable(for player: Player) {
        print("--> enable for \(id)")
    }

    func disable() {
        print("--> disable for \(id)")
    }

    func update(with metadata: Metadata) {
        print("--> update metadata for \(id): \(metadata)")
    }
}
