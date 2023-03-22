//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Player
import UIKit

public extension PlayerItem {
    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - environment: The environment which the URN is played from.
    static func urn<T>(
        _ urn: String,
        environment: Environment = .production,
        trackers: [TrackerAdapter<T, MediaMetadata>]
    ) -> Self where T: PlayerItemTracker {
        let dataProvider = DataProvider(environment: environment)
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
                        return Self.asset(for: metadata)
                    }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        return .init(publisher: publisher, trackers: trackers)
    }

    static func urn(
        _ urn: String,
        environment: Environment = .production
    ) -> Self {
        Self.urn(urn, environment: environment, trackers: [TrackerAdapter<EmptyTracker, MediaMetadata>]())
    }

    private static func asset(for metadata: MediaMetadata) -> Asset<MediaMetadata> {
        let resource = metadata.resource
        let configuration = assetConfiguration(for: resource)

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

    private static func assetConfiguration(for resource: Resource) -> ((AVPlayerItem) -> Void) {
        { item in
            guard resource.streamType == .live else { return }
            // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
            // livestreams cannot be paused and resumed in the past, as requested by business people.
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
        }
    }
}

private struct EmptyTracker: PlayerItemTracker {
    func enable(for player: Player) {}
    func disable() {}
    func update(with metadata: Void) {}
}
