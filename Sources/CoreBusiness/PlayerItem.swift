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
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, automaticallyLoadedAssetKeys: [String]? = nil, environment: Environment = .production) {
        // swiftlint:disable:previous discouraged_optional_collection
        let publisher = DataProvider(environment: environment).recommendedPlayableResource(forUrn: urn)
            .map { Self.configuredPlayerItem(for: $0, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys) }
        self.init(publisher: publisher)
    }

    private static func configuredPlayerItem(for resource: Resource, automaticallyLoadedAssetKeys: [String]?) -> AVPlayerItem {
        // swiftlint:disable:previous discouraged_optional_collection
        let item = playerItem(for: resource, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        if resource.streamType == .live {
            /// Limit buffering and force the player to return to the live edge when re-buffering. This ensures
            /// livestreams cannot be paused and resumed in the past, as requested by business people.
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
        }
        return item
    }

    private static func playerItem(for resource: Resource, automaticallyLoadedAssetKeys: [String]?) -> AVPlayerItem {
        // swiftlint:disable:previous discouraged_optional_collection
        if let certificateUrl = resource.drms?.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return AVPlayerItem.loading(
                url: resource.url,
                contentKeySessionDelegate: ContentKeySessionDelegate(certificateUrl: certificateUrl)
            )
        }
        else {
            switch resource.tokenType {
            case .akamai:
                return AVPlayerItem.loading(
                    url: AkamaiURLCoding.encodeUrl(resource.url),
                    resourceLoaderDelegate: AkamaiResourceLoaderDelegate()
                )
            default:
                return AVPlayerItem(url: resource.url)
            }
        }
    }
}
