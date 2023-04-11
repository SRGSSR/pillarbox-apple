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
        let labels: [String: String]

        public init(labels: [String: String] = [:]) {
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
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(PackageInfo.version)

        let metadata = SCORStreamingContentMetadata { [weak self] builder in
            guard let self else { return }
            builder!.setCustomLabels(self.configuration.labels)
        }
        streamingAnalytics.setMetadata(metadata)
        streamingAnalytics.notifyPlay()
    }

    public func disable() {
        print("--> disable comScore")
    }
}
