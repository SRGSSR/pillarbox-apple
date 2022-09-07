//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var resourceLoaderDelegateKey: Void?

public extension AVPlayerItem {
    convenience init(urn: String, environment: Environment = .production) {
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        self.init(asset: asset, associatedDelegate: AssetResourceLoaderDelegate(), queue: .global(qos: .userInteractive))
    }

    convenience init(asset: AVURLAsset, associatedDelegate delegate: AVAssetResourceLoaderDelegate, queue: DispatchQueue) {
        objc_setAssociatedObject(asset, &resourceLoaderDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        asset.resourceLoader.setDelegate(delegate, queue: queue)
        self.init(asset: asset)
    }
}
