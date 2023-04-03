//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Combine
import Foundation
import Player

/// Tracker for comScore stream tracking.
public final class ComScoreTracker: PlayerItemTracker {
    public struct Configuration {
        let labels: Analytics.Labels?

        public init(labels: Analytics.Labels? = nil) {
            self.labels = labels
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration, metadataPublisher: AnyPublisher<[String: String], Never>) {
        self.configuration = configuration
    }

    public func enable(for player: Player) {
        print("--> enable comScore")
    }

    public func disable() {
        print("--> disable comScore")
    }
}
