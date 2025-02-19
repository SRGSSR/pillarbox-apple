//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import ComScore
import PillarboxPlayer

/// A comScore tracker for streaming.
///
/// This tracker implements streaming measurements according to Mediapulse official specifications.
///
/// Analytics have to be properly started for the tracker to collect data, see `Analytics.start(with:)`.
public final class ComScoreTracker: PlayerItemTracker {
    private lazy var streamingAnalytics = ComScoreStreamingAnalytics()
    private var metadata: [String: String] = [:]

    // swiftlint:disable:next missing_docs
    public init(configuration: Void) {}

    // swiftlint:disable:next missing_docs
    public func enable(for player: AVPlayer) {
        createPlaybackSession()
    }

    // swiftlint:disable:next missing_docs
    public func updateMetadata(to metadata: [String: String]) {
        self.metadata = metadata
        setMetadata(metadata)
    }

    // swiftlint:disable:next missing_docs
    public func updateProperties(to properties: PlayerProperties) {
        guard !metadata.isEmpty else { return }

        AnalyticsListener.capture(streamingAnalytics.configuration())
        streamingAnalytics.setPlaybackPosition(from: properties)

        switch (properties.isSeeking, properties.isBuffering) {
        case (true, true):
            streamingAnalytics.notifySeekStart()
            streamingAnalytics.notifyBufferStart()
        case (true, false):
            streamingAnalytics.notifySeekStart()
            streamingAnalytics.notifyBufferStop()
        case (false, true):
            streamingAnalytics.notifyBufferStart()
        case (false, false):
            streamingAnalytics.notifyBufferStop()
            streamingAnalytics.notifyEvent(for: properties.playbackState, at: properties.rate)
        }
    }

    // swiftlint:disable:next missing_docs
    public func updateMetricEvents(to events: [MetricEvent]) {}

    // swiftlint:disable:next missing_docs
    public func disable(with properties: PlayerProperties) {
        streamingAnalytics = ComScoreStreamingAnalytics()
    }
}

private extension ComScoreTracker {
    func createPlaybackSession() {
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(Player.version)
        setMetadata(metadata)
    }

    func setMetadata(_ metadata: [String: String]) {
        let builder = SCORStreamingContentMetadataBuilder()
        if let globals = Analytics.shared.comScoreGlobals {
            builder.setCustomLabels(metadata.merging(globals.labels) { _, new in new })
        }
        else {
            builder.setCustomLabels(metadata)
        }
        let contentMetadata = SCORStreamingContentMetadata(builder: builder)
        streamingAnalytics.setMetadata(contentMetadata)
    }
}
