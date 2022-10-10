//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

private let assetResourceLoaders: [Environment: AssetResourceLoaderDelegate] = [
    .production: AssetResourceLoaderDelegate(environment: .production),
    .stage: AssetResourceLoaderDelegate(environment: .stage),
    .test: AssetResourceLoaderDelegate(environment: .test)
]

public extension AVPlayerItem {
    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, automaticallyLoadedAssetKeys: [String]? = nil, environment: Environment = .production) {
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        asset.resourceLoader.setDelegate(assetResourceLoaders[environment], queue: .global(qos: .userInitiated))
        self.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}
