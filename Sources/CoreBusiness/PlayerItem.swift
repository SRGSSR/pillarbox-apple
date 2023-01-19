//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

public extension PlayerItem {
    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, environment: Environment = .production) {
        let publisher = DataProvider(environment: environment).playableMediaComposition(forUrn: urn)
            .tryMap { try Self.asset(for: $0) }
        self.init(publisher: publisher)
    }

    private static func asset(for mediaComposition: MediaComposition) throws -> Asset {
        let mainChapter = mediaComposition.mainChapter
        guard let resource = mainChapter.recommendedResource else {
            throw DataError.noResourceAvailable
        }
        
        return .init(
            type: assetType(for: resource),
            metadata: assetMetadata(for: mainChapter, of: mediaComposition.show)
        ) { item in
            guard resource.streamType == .live else { return }
            // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
            // livestreams cannot be paused and resumed in the past, as requested by business people.
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
        }
    }

    private static func assetMetadata(for chapter: Chapter, of show: Show?) -> Asset.Metadata {
        .init(
            title: chapter.title,
            subtitle: show?.title ?? "",
            description: chapter.description ?? ""
        )
    }

    private static func assetType(for resource: Resource) -> Asset.`Type` {
        if let certificateUrl = resource.drms?.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .encrypted(url: resource.url, delegate: ContentKeySessionDelegate(certificateUrl: certificateUrl))
        }
        else {
            switch resource.tokenType {
            case .akamai:
                let id = UUID()
                return .custom(url: AkamaiURLCoding.encodeUrl(resource.url, id: id), delegate: AkamaiResourceLoaderDelegate(id: id))
            default:
                return .simple(url: resource.url)
            }
        }
    }
}
