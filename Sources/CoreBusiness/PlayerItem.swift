//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxAnalytics
import PillarboxPlayer

public extension PlayerItem {
    /// Creates a player item from a URN.
    ///
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - server: The server which the URN is played from.
    ///   - metadataAdapter: A `MetadataAdapter` converting item metadata into player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    ///
    /// In addition the item is automatically tracked according to SRG SSR analytics standards.
    static func urn(
        _ urn: String,
        server: Server = .production,
        metadataAdapter: MetadataAdapter<MediaMetadata> = .standard,
        trackerAdapters: [TrackerAdapter<MediaMetadata>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        let dataProvider = DataProvider(server: server)
        let publisher = dataProvider.playableMediaCompositionPublisher(forUrn: urn)
            .tryMap { mediaComposition in
                let mainChapter = mediaComposition.mainChapter
                guard let resource = mainChapter.recommendedResource else {
                    throw DataError.noResourceAvailable
                }
                return dataProvider.imagePublisher(for: mainChapter.imageUrl, width: .width480)
                    .map { Optional($0) }
                    .replaceError(with: nil)
                    .prepend(nil)
                    .map { image in
                        let metadata = MediaMetadata(mediaComposition: mediaComposition, resource: resource, image: image)
                        return Self.asset(for: metadata, configuration: configuration)
                    }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        return .init(publisher: publisher, metadataAdapter: metadataAdapter, trackerAdapters: [
            ComScoreTracker.adapter { $0.analyticsData },
            CommandersActTracker.adapter { $0.analyticsMetadata }
        ] + trackerAdapters)
    }

    private static func asset(for metadata: MediaMetadata, configuration: @escaping (AVPlayerItem) -> Void) -> Asset<MediaMetadata> {
        let resource = metadata.resource
        let configuration = assetConfiguration(for: resource, configuration: configuration)

        if let certificateUrl = resource.drms.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .encrypted(
                url: resource.url,
                delegate: ContentKeySessionDelegate(certificateUrl: certificateUrl),
                metadata: metadata,
                configuration: configuration
            )
        }
        else {
            switch resource.tokenType {
            case .akamai:
                let id = UUID()
                return .custom(
                    url: AkamaiURLCoding.encodeUrl(resource.url, id: id),
                    delegate: AkamaiResourceLoaderDelegate(id: id),
                    metadata: metadata,
                    configuration: configuration
                )
            default:
                return .simple(url: resource.url, metadata: metadata, configuration: configuration)
            }
        }
    }

    private static func assetConfiguration(for resource: Resource, configuration: @escaping (AVPlayerItem) -> Void) -> ((AVPlayerItem) -> Void) {
        { item in
            configuration(item)

            // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
            // livestreams cannot be paused and resumed in the past, as requested by business people.
            //
            // This setup is performed after any custom configuration to avoid being overridden.
            guard resource.streamType == .live else { return }
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
        }
    }
}
