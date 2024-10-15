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

public extension PlayerItem {
    /// Creates a player item from a URN.
    ///
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - server: The server which the URN is played from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    ///
    /// Metadata is automatically associated with the item. In addition to trackers you provide, tracking is performed
    /// according to SRG SSR analytics standards.
    static func urn(
        _ urn: String,
        server: Server = .production,
        trackerAdapters: [TrackerAdapter<MediaMetadata>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            publisher: publisher(forUrn: urn, server: server, configuration: configuration),
            trackerAdapters: [
                ComScoreTracker.adapter { $0.analyticsData },
                CommandersActTracker.adapter { $0.analyticsMetadata },
                MetricsTracker.adapter(
                    configuration: .init(
                        serviceUrl: URL(string: "https://monitoring.pillarbox.ch/api/events")!
                    ),
                    behavior: .mandatory
                ) { metadata in
                    MetricsTracker.Metadata(
                        identifier: metadata.mainChapter.urn,
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
    ///   - configuration: The configuration to apply to the player item.
    ///
    /// No SRG SSR standard tracking is made. Use `ComScoreTracker` and `CommandersActTracker` to implement standard
    /// tracking.
    static func tokenProtected<M>(
        url: URL,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .tokenProtected(url: url, metadata: metadata, configuration: configuration),
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
    /// No SRG SSR standard tracking is made. Use `ComScoreTracker` and `CommandersActTracker` to implement standard
    /// tracking.
    static func encrypted<M>(
        url: URL,
        certificateUrl: URL,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .encrypted(url: url, certificateUrl: certificateUrl, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters
        )
    }
}

private extension PlayerItem {
    static func publisher(forUrn urn: String, server: Server, configuration: PlayerItemConfiguration) -> AnyPublisher<Asset<MediaMetadata>, Error> {
        let dataProvider = DataProvider(server: server)
        return dataProvider.mediaCompositionPublisher(forUrn: urn)
            .tryMap { response in
                let metadata = try MediaMetadata(mediaCompositionResponse: response, dataProvider: dataProvider)
                return asset(metadata: metadata, configuration: configuration, dataProvider: dataProvider)
            }
            .eraseToAnyPublisher()
    }

    private static func asset(metadata: MediaMetadata, configuration: PlayerItemConfiguration, dataProvider: DataProvider) -> Asset<MediaMetadata> {
        if let blockingReason = metadata.blockingReason {
            return .unavailable(with: DataError.blocked(withMessage: blockingReason.description), metadata: metadata)
        }
        guard let resource = metadata.resource else {
            return .unavailable(with: DataError.noResourceAvailable, metadata: metadata)
        }
        let configuration = assetConfiguration(for: resource, configuration: configuration)
        if let certificateUrl = resource.drms.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .encrypted(url: resource.url, certificateUrl: certificateUrl, metadata: metadata, configuration: configuration)
        }
        else {
            switch resource.tokenType {
            case .akamai:
                return .tokenProtected(url: resource.url, metadata: metadata, configuration: configuration)
            default:
                return .simple(url: resource.url, metadata: metadata, configuration: configuration)
            }
        }
    }

    private static func assetConfiguration(
        for resource: MediaComposition.Resource,
        configuration: PlayerItemConfiguration
    ) -> PlayerItemConfiguration {
        // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
        // livestreams cannot be paused and resumed in the past, as requested by business people.
        guard resource.streamType == .live else { return configuration }
        return .init(position: configuration.position, automaticallyPreservesTimeOffsetFromLive: true, preferredForwardBufferDuration: 1)
    }
}
