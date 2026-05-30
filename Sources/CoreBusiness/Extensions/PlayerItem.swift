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
    ///   - configuration: The configuration to apply to the player item.
    ///   - commandersActSource: The source of events sent to Commanders Act.
    ///
    /// Metadata is automatically associated with the item. In addition to trackers you provide, tracking is performed
    /// according to SRG SSR analytics standards.
    static func urn(
        _ urn: String,
        server: Server = .production,
        trackerAdapters: [TrackerAdapter<MediaMetadata>] = [],
        configuration: PlaybackConfiguration = .default,
        commandersActSource: CommandersActSource? = nil
    ) -> Self {
        self.init(
            assetLoaderType: URNAssetLoader.self,
            input: .init(urn: urn, server: server, configuration: configuration),
            trackerAdapters: [
                ComScoreTracker.adapter { $0.analyticsData },
                CommandersActTracker.adapter(configuration: commandersActSource) { $0.analyticsMetadata },
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
}

@_spi(CoreBusinessPrivate)
public extension PlayerItem {
    /// Creates a player item from a URL, loaded with standard SRG SSR token protection.
    ///
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    ///
    /// No SRG SSR standard tracking is made.
    ///
    /// > Important: This API is reserved to the Pillarbox development team.
    static func tokenProtected(
        url: URL,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        self.init(
            assetLoaderType: TokenProtectedAssetLoader.self,
            input: .init(url: url, metadata: metadata, configuration: configuration),
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
    ///   - configuration: The configuration to apply to the player item.
    ///
    /// No SRG SSR standard tracking is made.
    ///
    /// > Important: This API is reserved to the Pillarbox development team.
    static func encrypted(
        url: URL,
        certificateUrl: URL,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        self.init(
            assetLoaderType: EncryptedAssetLoader.self,
            input: .init(url: url, certificateUrl: certificateUrl, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters
        )
    }
}
