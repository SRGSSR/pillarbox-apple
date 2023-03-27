//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import OSLog
import Player

final class DemoTracker: PlayerItemTracker {
    struct Metadata {
        let title: String
    }

    private static let logger = Logger(category: "DemoTracker")

    private let id = UUID()

    init(configuration: Void) {
        Self.logger.debug("Init demo tracker \(self.id)")
    }

    func enable(for player: Player) {
        Self.logger.debug("Enable demo tracker for \(self.id)")
    }

    func disable() {
        Self.logger.debug("Disable demo tracker for \(self.id)")
    }

    func update(metadata: Metadata) {
        Self.logger.debug("Update demo tracker metadata for \(self.id): \(metadata.title)")
    }

    deinit {
        Self.logger.debug("Deinit demo tracker \(self.id)")
    }
}
