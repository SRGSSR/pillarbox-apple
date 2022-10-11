//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public class PlayerItem: AVPlayerItem {
    private let resourceLoaderDelegate: AssetResourceLoaderDelegate

    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play.
    ///   - environment: The environment which the URN is played from.
    public init(urn: String, automaticallyLoadedAssetKeys keys: [String], environment: Environment = .production) {
        resourceLoaderDelegate = AssetResourceLoaderDelegate(environment: environment)
        super.init(asset: Self.asset(fromUrn: urn, resourceLoaderDelegate: resourceLoaderDelegate), automaticallyLoadedAssetKeys: keys)
        preventLivestreamDelayedPlayback()
    }

    /// Create a player item from a URN played in the specified environment. Loads standard asset keys before the item
    /// is ready to play.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - environment: The environment which the URN is played from.
    public init(urn: String, environment: Environment = .production) {
        resourceLoaderDelegate = AssetResourceLoaderDelegate(environment: environment)
        super.init(asset: Self.asset(fromUrn: urn, resourceLoaderDelegate: resourceLoaderDelegate))
        preventLivestreamDelayedPlayback()
    }

    private static func asset(fromUrn urn: String, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) -> AVAsset {
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))
        return asset
    }

    /// Limit buffering and force the player to return to the live edge when re-buffering. This ensures livestreams
    /// cannot be paused and resumed in the past, as requested by business people.
    ///
    /// Remark: These settings do not negatively affect on-demand or DVR livestream playback.
    private func preventLivestreamDelayedPlayback() {
        automaticallyPreservesTimeOffsetFromLive = true
        preferredForwardBufferDuration = 1
    }
}
