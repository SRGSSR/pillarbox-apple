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
    static func urn(_ urn: String, environment: Environment = .production) -> Self {
        let dataProvider = DataProvider(environment: environment)
        let publisher = dataProvider.playableMediaCompositionPublisher(forUrn: urn)
            .tryMap { mediaComposition in
                let mainChapter = mediaComposition.mainChapter
                guard let resource = mainChapter.recommendedResource else {
                    throw DataError.noResourceAvailable
                }
                return dataProvider.imagePublisher(for: mediaComposition.mainChapter.imageUrl, width: .width480)
                    .map { Optional($0) }
                    .replaceError(with: nil)
                    .prepend(nil)
                    .map { image in
                        let metadata = Self.assetMetadata(for: mediaComposition, image: image)
                        return Self.asset(for: resource, metadata: metadata)
                    }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        return .init(publisher: publisher)
    }

    private static func assetMetadata(for mediaComposition: MediaComposition, image: UIImage?) -> Asset.Metadata {
        let chapter = mediaComposition.mainChapter
        return .init(
            title: chapter.title,
            subtitle: mediaComposition.show?.title,
            description: chapter.description,
            image: image
        )
    }

    private static func asset(for resource: Resource, metadata: Asset.Metadata) -> Asset {
        let configuration = assetConfiguration(for: resource)

        if let certificateUrl = resource.drms?.first(where: { $0.type == .fairPlay })?.certificateUrl {
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
