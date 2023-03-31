//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player

/// Tracker for comScore stream tracking.
public final class ComScoreTracker: PlayerItemTracker {
    public struct Configuration {
        let labels: [String: String]

        public init(labels: [String: String] = [:]) {
            self.labels = labels
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration, metadataPublisher: AnyPublisher<[String: String], Never>) {
        self.configuration = configuration
    }

    public func enable(for player: Player) {
        print("--> enable comScore \(configuration.labels)")
    }

    public func disable() {
        print("--> disable comScore \(configuration.labels)")
    }
}
