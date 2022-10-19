//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public extension AVPlayerItem {
    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play.
    convenience init(url: URL, automaticallyLoadedAssetKeys keys: [String]) {
        let asset = AVURLAsset(url: url)
        self.init(asset: asset, automaticallyLoadedAssetKeys: keys)
    }
}

public final class PlayerItem {
    @Published var playerItem: AVPlayerItem = LoadingPlayerItem()

    init<P>(publisher: P) where P: Publisher, P.Output == AVPlayerItem {
        publisher
            .catch { error in
                Just(FailingPlayerItem(error: error))
            }
            .assign(to: &$playerItem)
    }
}

extension PlayerItem {
    private static func item(url: URL, automaticallyLoadedAssetKeys: [String]?) -> AVPlayerItem {
        if let automaticallyLoadedAssetKeys {
            return AVPlayerItem(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        }
        else {
            return AVPlayerItem(url: url)
        }
    }

    convenience init(url: URL, automaticallyLoadedAssetKeys: [String]? = nil) {
        let item = Self.item(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.init(publisher: Just(item))
    }

    convenience init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]? = nil) {
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.init(publisher: Just(item))
    }
}

/// An item which never loads.
final class LoadingPlayerItem: AVPlayerItem {
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init() {
        resourceLoaderDelegate = LoadingResourceLoaderDelegate()
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        let asset = AVURLAsset(url: URL(string: "pillarbox://loading.m3u8")!)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
    }
}

/// An item which immediately fails with a specific error.
final class FailingPlayerItem: AVPlayerItem {
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(error: Error) {
        resourceLoaderDelegate = FailingResourceLoaderDelegate(error: error)
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        let asset = AVURLAsset(url: URL(string: "pillarbox://failing.m3u8")!)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
    }
}

private final class LoadingResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource
        renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        true
    }
}

private final class FailingResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let error: Error

    init(error: Error) {
        self.error = error
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        loadingRequest.finishLoading(with: error)
        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource
        renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        true
    }
}
