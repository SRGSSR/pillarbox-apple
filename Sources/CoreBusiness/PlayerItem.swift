//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var resourceLoaderDelegateKey: Void?

public extension AVPlayerItem {
    convenience init(urn: String, environment: Environment = .production) {
        let encodedUrn = urn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let asset = AVURLAsset(url: URL(string: "urn://mediacomposition?urn=\(encodedUrn)")!)

        let resourceLoaderDelegate = AssetResourceLoaderDelegate()
        objc_setAssociatedObject(asset, &resourceLoaderDelegateKey, resourceLoaderDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue(label: "ch.srgssr.pillarbox.resource-loader-delegate"))

        self.init(asset: asset)
    }
}
