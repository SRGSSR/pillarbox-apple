//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var resourceLoaderDelegateKey: Void?

public extension AVPlayerItem {
    /// Create a player item from an asset loaded with a given resource loader delegate. The delegate is retained
    /// by the player item automatically.
    /// - Parameters:
    ///   - asset: The asset.
    ///   - delegate: The resource loader delegate (retained):
    ///   - queue: The queue onto which delegate methods must be called.
    convenience init(asset: AVURLAsset, associatedDelegate delegate: AVAssetResourceLoaderDelegate, queue: DispatchQueue) {
        objc_setAssociatedObject(asset, &resourceLoaderDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        asset.resourceLoader.setDelegate(delegate, queue: queue)
        self.init(asset: asset)
    }
}
