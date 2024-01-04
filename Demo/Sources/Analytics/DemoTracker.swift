//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import os
import PillarboxPlayer

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

    func updateMetadata(with metadata: Metadata) {
        Self.logger.debug("Update demo tracker metadata for \(self.id): \(metadata.title)")
    }

    func updateProperties(with properties: PlayerProperties) {}

    func disable() {
        Self.logger.debug("Disable demo tracker for \(self.id)")
    }

    deinit {
        Self.logger.debug("Deinit demo tracker \(self.id)")
    }
}
