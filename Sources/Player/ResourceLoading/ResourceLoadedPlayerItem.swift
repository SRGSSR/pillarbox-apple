//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private let kResourceLoaderQueue = DispatchQueue(label: "ch.srgssr.player.resource-loader")

/// An item which stores its own custom resource loader delegate.
final class ResourceLoadedPlayerItem: AVPlayerItem {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(asset: AVURLAsset, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: kResourceLoaderQueue)
        // Provide same key as for a standard asset, see `AVPlayerItem.init(asset:)` documentation.
        super.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
    }
}
