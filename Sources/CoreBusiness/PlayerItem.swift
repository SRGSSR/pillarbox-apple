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
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play, ensuring they are
    ///     available, but increasing startup time.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, automaticallyLoadedAssetKeys: [String], environment: Environment = .production) {
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        asset.resourceLoader.setDelegate(kAssetResourceLoaders[environment], queue: .global(qos: .userInitiated))
        self.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}
