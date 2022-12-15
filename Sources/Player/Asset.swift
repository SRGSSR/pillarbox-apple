//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private let kContentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)

private let kResourceLoaderQueue = DispatchQueue(label: "ch.srgssr.player.resource_loader")
private let kContentKeySessionQueue = DispatchQueue(label: "ch.srgssr.player.content_key_session")

/// An item which stores its own custom resource loader delegate.
final class ResourceLoadedPlayerItem: AVPlayerItem {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(url: URL, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: kResourceLoaderQueue)
        // Provide same key as for a standard asset, as documented for `AVPlayerItem.init(asset:)`.
        super.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
    }
}

/// An asset representing content to be played.
public struct Asset {
    private enum `Type` {
        case simple(url: URL)
        case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
        case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

        func playerItem() -> AVPlayerItem {
            switch self {
            case let .simple(url: url):
                return AVPlayerItem(url: url)
            case let .custom(url: url, delegate: delegate):
                return ResourceLoadedPlayerItem(
                    url: url,
                    resourceLoaderDelegate: delegate
                )
            case let .encrypted(url: url, delegate: delegate):
                let asset = AVURLAsset(url: url)
                kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
                kContentKeySession.addContentKeyRecipient(asset)
                kContentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
                return AVPlayerItem(asset: asset)
            }
        }
    }

    private let type: `Type`
    private let configuration: (AVPlayerItem) -> Void

    /// A simple asset playable from a URL.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - configuration: A closure to configure player items created from the receiver.
    public static func simple(
        url: URL,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .simple(url: url),
            configuration: configuration
        )
    }

    /// An asset loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - configuration: A closure to configure player items created from the receiver.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .custom(url: url, delegate: delegate),
            configuration: configuration
        )
    }

    /// An encrypted asset loaded with a content key session.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - configuration: A closure to configure player items created from the receiver.
    public static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .encrypted(url: url, delegate: delegate),
            configuration: configuration
        )
    }

    func playerItem() -> AVPlayerItem {
        let item = type.playerItem()
        configuration(item)
        return item
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
