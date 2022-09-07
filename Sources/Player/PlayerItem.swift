//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var resourceLoaderDelegateKey: Void?

public extension AVPlayerItem {
    convenience init(asset: AVURLAsset, associatedDelegate delegate: AVAssetResourceLoaderDelegate, queue: DispatchQueue) {
        objc_setAssociatedObject(asset, &resourceLoaderDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        asset.resourceLoader.setDelegate(delegate, queue: queue)
        self.init(asset: asset)
    }
}
