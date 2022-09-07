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

        let resourceLoaderDelegate = AssetResourceLoaderDelegate()
        objc_setAssociatedObject(asset, &resourceLoaderDelegateKey, resourceLoaderDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))

        self.init(asset: asset)
    }
}
