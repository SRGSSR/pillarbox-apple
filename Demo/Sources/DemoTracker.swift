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
        Self.logger.debug("--> init demo tracker \(self.id)")
    }

    func enable(for player: Player) {
        Self.logger.debug("--> enable demo tracker for \(self.id)")
    }

    func disable() {
        Self.logger.debug("--> disable demo tracker for \(self.id)")
    }

    func update(metadata: Metadata) {
        Self.logger.debug("--> update demo tracker metadata for \(self.id): \(metadata.title)")
    }

    deinit {
        Self.logger.debug("--> deinit demo tracker \(self.id)")
    }
}
