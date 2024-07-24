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

    func updateProperties(with properties: PlayerProperties, time: CMTime) {}

    func receiveMetricEvent(_ event: MetricEvent) {
        Self.logger.debug("Receive metric event for \(self.id): \(event)")
    }

    func disable(with properties: PlayerProperties, time: CMTime) {
        Self.logger.debug("Disable demo tracker for \(self.id) - \(time.seconds)")
    }

    deinit {
        Self.logger.debug("Deinit demo tracker \(self.id)")
    }
}
