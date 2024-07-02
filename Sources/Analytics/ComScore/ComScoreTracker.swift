//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
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
    private weak var player: Player?

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
        createPlaybackSession()
    }

    public func updateMetadata(with metadata: [String: String]) {
        self.metadata = metadata
        addMetadata(metadata)
    }

    public func updateProperties(with properties: PlayerProperties) {
        guard !metadata.isEmpty, let player else { return }

        AnalyticsListener.capture(streamingAnalytics.configuration())
        streamingAnalytics.setProperties(for: properties, time: player.time, streamType: properties.streamType)

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
            renewPlaybackSessionIfNeeded(for: properties.playbackState)
        }
    }

    public func updateMetrics(with events: [MetricEvent]) {}

    public func disable() {
        streamingAnalytics = ComScoreStreamingAnalytics()
        player = nil
    }

    private func renewPlaybackSessionIfNeeded(for playbackState: PlaybackState) {
        guard playbackState == .ended else { return }
        createPlaybackSession()
        addMetadata(metadata)
    }

    private func createPlaybackSession() {
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(Player.version)
    }

    private func addMetadata(_ metadata: [String: String]) {
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
