//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxAnalytics
import PillarboxMonitoring
import PillarboxPlayer

@_spi(StandardConnectorPrivate)
import PillarboxStandardConnector

public extension PlayerItem {
    /// Creates a player item from a URN.
    ///
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - server: The server which the URN is played from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - context: Contextual information associated with the item.
    ///
    /// Metadata is automatically associated with the item. In addition to trackers you provide, tracking is performed
    /// according to SRG SSR analytics standards.
    static func urn(
        _ urn: String,
        server: Server = .production,
        trackerAdapters: [TrackerAdapter<MediaMetadata>] = [],
        context: PlaybackContext = .default
    ) -> Self {
        self.init(
            assetLoader: URNAssetLoader.self,
            input: .init(urn: urn, server: server, configuration: context.configuration),
            trackerAdapters: [
                ComScoreTracker.adapter { $0.analyticsData },
                CommandersActTracker.adapter(configuration: context.commandersActSource) { $0.analyticsMetadata },
                MetricsTracker.adapter(
                    configuration: .init(
                        identifier: urn,
                        serviceUrl: URL(string: "https://monitoring.pillarbox.ch/api/events")!
                    ),
                    behavior: .mandatory
                ) { metadata in
                    MetricsTracker.Metadata(
                        metadataUrl: metadata.mediaCompositionUrl,
                        assetUrl: metadata.resource?.url
                    )
                }
            ] + trackerAdapters
        )
    }

    /// Creates a player item from a URL, loaded with standard SRG SSR token protection.
    ///
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - context: Contextual information associated with the item.
    ///
    /// No SRG SSR standard tracking is made. Use `ComScoreTracker` and `CommandersActTracker` to implement standard
    /// tracking.
    static func tokenProtected(
        url: URL,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        context: PlaybackContext = .default
    ) -> Self {
        self.init(
            asset: .tokenProtected(url: url, metadata: metadata, configuration: context.configuration),
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates a player item from a URL, loaded with standard SRG SSR DRM protection.
    ///
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - certificateUrl: The URL of the certificate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - context: Contextual information associated with the item.
    ///
    /// No SRG SSR standard tracking is made. Use `ComScoreTracker` and `CommandersActTracker` to implement standard
    /// tracking.
    static func encrypted(
        url: URL,
        certificateUrl: URL,
        metadata: PlayerMetadata,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        context: PlaybackContext = .default
    ) -> Self {
        self.init(
            asset: .encrypted(url: url, certificateUrl: certificateUrl, metadata: metadata, configuration: context.configuration),
            trackerAdapters: trackerAdapters
        )
    }
}
