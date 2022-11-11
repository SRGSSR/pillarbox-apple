//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

public extension PlayerItem {
    // swiftlint:disable discouraged_optional_collection

    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, automaticallyLoadedAssetKeys: [String]? = nil, environment: Environment = .production) {
        let publisher = DataProvider(environment: environment).recommendedPlayableResource(forUrn: urn)
            .map { Self.playerItem(for: $0, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys) }
        self.init(publisher: publisher)
    }

    // swiftlint:enable discouraged_optional_collection

    private static func url(for resource: Resource) -> URL {
        switch resource.tokenType {
        case .akamai:
            return AkamaiURLCoding.encodeUrl(resource.url)
        default:
            return resource.url
        }
    }

    private static func resourceLoaderDelegate(for resource: Resource) -> AVAssetResourceLoaderDelegate? {
        switch resource.tokenType {
        case .akamai:
            return AkamaiResourceLoaderDelegate()
        default:
            return nil
        }
    }

    private static func playerItem(for resource: Resource, automaticallyLoadedAssetKeys: [String]?) -> AVPlayerItem {
        let item = AVPlayerItem.loading(
            url: url(for: resource),
            resourceLoaderDelegate: resourceLoaderDelegate(for: resource)
        )
        if resource.streamType == .live {
            /// Limit buffering and force the player to return to the live edge when re-buffering. This ensures
            /// livestreams cannot be paused and resumed in the past, as requested by business people.
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
        }
        return item
    }
}
