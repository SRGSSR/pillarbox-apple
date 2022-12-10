//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private let contentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)

private let resourceLoaderQueue = DispatchQueue(label: "ch.srgssr.player.resource_loader")
private let contentKeySessionQueue = DispatchQueue(label: "ch.srgssr.player.content_key_session")

/// An item which stores its own custom resource loader delegate.
final class ResourceLoadedPlayerItem: AVPlayerItem {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(url: URL, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
    }
}

/// An asset representing content to be played.
public enum Asset {
    /// A simple asset playable from a URL.
    case simple(url: URL)
    /// An asset loaded with custom resource loading.
    case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
    /// An encrypted asset loaded with a content key session.
    case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

    func playerItem() -> AVPlayerItem {
        switch self {
        case let .simple(url: url):
            return AVPlayerItem(url: url)
        case let .custom(url: url, delegate: delegate):
            return ResourceLoadedPlayerItem(url: url, resourceLoaderDelegate: delegate)
        case let .encrypted(url: url, delegate: delegate):
            let asset = AVURLAsset(url: url)
            contentKeySession.setDelegate(delegate, queue: contentKeySessionQueue)
            contentKeySession.addContentKeyRecipient(asset)
            contentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
            return AVPlayerItem(asset: asset)
        }
    }
}

extension Asset {
    static var loading: Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .custom(
            url: URL(string: "pillarbox://loading.m3u8")!,
            delegate: LoadingResourceLoaderDelegate()
        )
    }

    static func failed(error: Error) -> Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .custom(
            url: URL(string: "pillarbox://failing.m3u8")!,
            delegate: FailedResourceLoaderDelegate(error: error)
        )
    }
}
