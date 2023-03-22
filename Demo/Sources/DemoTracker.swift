//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

final class DemoTracker: PlayerItemTracker {
    struct Metadata {
        let title: String
    }

    private let id = UUID()

    init() {
        print("--> init \(id)")
    }

    func enable(for player: Player) {
        print("--> enable for \(id)")
    }

    func disable() {
        print("--> disable for \(id)")
    }

    func update(with metadata: Metadata) {
        print("--> update metadata for \(id): \(metadata)")
    }

    deinit {
        print("--> deinit \(id)")
    }
}
