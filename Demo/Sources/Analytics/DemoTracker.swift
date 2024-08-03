//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
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

    func enable(for player: AVPlayer) {
        Self.logger.debug("Enable demo tracker for \(self.id)")
    }

    func updateMetadata(with metadata: Metadata) {
        Self.logger.debug("Update demo tracker metadata for \(self.id): \(metadata.title)")
    }

    func updateProperties(with properties: PlayerProperties) {}

    func updateMetricEvents(with events: [MetricEvent]) {
        Self.logger.debug("Update demo tracker metric events for \(self.id): \(events)")
    }

    func disable(with properties: PlayerProperties) {
        Self.logger.debug("Disable demo tracker for \(self.id) - \(properties.time().seconds)")
    }

    deinit {
        Self.logger.debug("Deinit demo tracker \(self.id)")
    }
}
