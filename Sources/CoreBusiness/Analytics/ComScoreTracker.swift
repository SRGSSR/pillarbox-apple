//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Combine
import ComScore
import Foundation
import Player

/// Stream tracker for comScore.
public final class ComScoreTracker: PlayerItemTracker {
    public struct Configuration {
        let labels: Analytics.Labels?

        public init(labels: Analytics.Labels? = nil) {
            self.labels = labels
        }
    }

    private let configuration: Configuration
    private let streamingAnalytics = SCORStreamingAnalytics()

    public init(configuration: Configuration, metadataPublisher: AnyPublisher<[String: String], Never>) {
        self.configuration = configuration
    }

    public func enable(for player: Player) {
        print("--> enable comScore")
        streamingAnalytics.createPlaybackSession()

        if let labels = configuration.labels?.comScore {
            let metadata = SCORStreamingContentMetadata { builder in
                builder!.setCustomLabels(labels)
            }
            streamingAnalytics.setMetadata(metadata)
        }
        streamingAnalytics.notifyPlay()
    }

    public func disable() {
        print("--> disable comScore")
    }
}
