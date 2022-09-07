//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var resourceLoaderDelegateKey: Void?

// TODO: Move URL creation / interpretation code to a common file

public extension AVPlayerItem {
    convenience init(urn: String, environment: Environment = .production) {
        let encodedUrn = urn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let asset = AVURLAsset(url: URL(string: "urn://mediacomposition?urn=\(encodedUrn)")!)
        self.init(asset: asset, associatedDelegate: AssetResourceLoaderDelegate(), queue: .global(qos: .userInteractive))
    }

    convenience init(asset: AVURLAsset, associatedDelegate delegate: AVAssetResourceLoaderDelegate, queue: DispatchQueue) {
        objc_setAssociatedObject(asset, &resourceLoaderDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        asset.resourceLoader.setDelegate(delegate, queue: queue)
        self.init(asset: asset)
    }
}
