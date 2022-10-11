//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private let kAssetResourceLoaders: [Environment: AssetResourceLoaderDelegate] = [
    .production: AssetResourceLoaderDelegate(environment: .production),
    .stage: AssetResourceLoaderDelegate(environment: .stage),
    .test: AssetResourceLoaderDelegate(environment: .test)
]

public extension AVPlayerItem {
    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, automaticallyLoadedAssetKeys keys: [String]? = nil, environment: Environment = .production) {
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        asset.resourceLoader.setDelegate(kAssetResourceLoaders[environment], queue: .global(qos: .userInitiated))
        self.init(asset: asset, automaticallyLoadedAssetKeys: keys)

        // Limit buffering. This ensures that paused livestreams without DVR cannot be played from buffer. Instead
        // force the player to return to the live edge when re-buffering live content.
        automaticallyPreservesTimeOffsetFromLive = true
        preferredForwardBufferDuration = 1
    }
}
