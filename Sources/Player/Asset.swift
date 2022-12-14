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

    init(url: URL, resourceLoaderDelegate: AVAssetResourceLoaderDelegate, automaticallyLoadedAssetKeys: [String]?) {
        // swiftlint:disable:previous discouraged_optional_collection
        self.resourceLoaderDelegate = resourceLoaderDelegate
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: kResourceLoaderQueue)
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}

/// An asset representing content to be played.
public struct Asset {
    private enum `Type` {
        case simple(url: URL)
        case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
        case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

        func playerItem(automaticallyLoadedAssetKeys: [String]?) -> AVPlayerItem {
            // swiftlint:disable:previous discouraged_optional_collection
            switch self {
            case let .simple(url: url):
                let asset = AVURLAsset(url: url)
                return AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
            case let .custom(url: url, delegate: delegate):
                return ResourceLoadedPlayerItem(
                    url: url,
                    resourceLoaderDelegate: delegate,
                    automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys
                )
            case let .encrypted(url: url, delegate: delegate):
                let asset = AVURLAsset(url: url)
                kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
                kContentKeySession.addContentKeyRecipient(asset)
                kContentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
                return AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
            }
        }
    }

    private let type: `Type`
    // swiftlint:disable:next discouraged_optional_collection
    private let automaticallyLoadedKeys: [String]?
    private let configuration: (AVPlayerItem) -> Void

    /// A simple asset playable from a URL.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - automaticallyLoadedKeys: Keys to be loaded before the item generated from the asset is ready to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public static func simple(
        url: URL,
        // swiftlint:disable:next discouraged_optional_collection
        automaticallyLoadedKeys: [String]? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .simple(url: url),
            automaticallyLoadedKeys: automaticallyLoadedKeys,
            configuration: configuration
        )
    }

    /// An asset loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - automaticallyLoadedKeys: Keys to be loaded before the item generated from the asset is ready to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        // swiftlint:disable:next discouraged_optional_collection
        automaticallyLoadedKeys: [String]? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .custom(url: url, delegate: delegate),
            automaticallyLoadedKeys: automaticallyLoadedKeys,
            configuration: configuration
        )
    }

    /// An encrypted asset loaded with a content key session.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - automaticallyLoadedKeys: Keys to be loaded before the item generated from the asset is ready to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        // swiftlint:disable:next discouraged_optional_collection
        automaticallyLoadedKeys: [String]? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .encrypted(url: url, delegate: delegate),
            automaticallyLoadedKeys: automaticallyLoadedKeys,
            configuration: configuration
        )
    }

    func playerItem() -> AVPlayerItem {
        let item = type.playerItem(automaticallyLoadedAssetKeys: automaticallyLoadedKeys)
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
