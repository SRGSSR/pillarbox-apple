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
        print("--> init demo tracker \(id)")
    }

    func enable(for player: Player) {
        print("--> enable demo tracker for \(id)")
    }

    func disable() {
        print("--> disable demo tracker for \(id)")
    }

    func update(metadata: Metadata) {
        print("--> update demo tracker metadata for \(id): \(metadata)")
    }

    deinit {
        print("--> deinit demo tracker \(id)")
    }
}
