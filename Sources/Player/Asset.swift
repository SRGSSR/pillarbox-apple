//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer

private var kIdKey: Void?

private let kResourceLoaderQueue = DispatchQueue(label: "ch.srgssr.player.resource_loader")

/// An item which stores its own custom resource loader delegate.
final class ResourceLoadedPlayerItem: AVPlayerItem {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(url: URL, resourceLoaderDelegate: AVAssetResourceLoaderDelegate) {
        self.resourceLoaderDelegate = resourceLoaderDelegate
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: kResourceLoaderQueue)
        // Provide same key as for a standard asset, see `AVPlayerItem.init(asset:)` documentation.
        super.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
    }
}

/// An asset representing content to be played.
///
/// Three categories of assets are provided:
///
/// - Simple assets which can be played directly.
/// - Custom assets which require a custom resource loader delegate.
/// - Encrypted assets which require a FairPlay content key session delegate.
public struct Asset<M>: Assetable where M: AssetMetadata {
    let id: UUID
    let resource: Resource
    private let metadata: M?
    private let configuration: (AVPlayerItem) -> Void
    private let trackerAdapters: [TrackerAdapter<M>]

    /// Returns a simple asset playable from a URL.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func simple(
        url: URL,
        metadata: M,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            resource: .simple(url: url),
            metadata: metadata,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// Returns an asset loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            resource: .custom(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// Returns an encrypted asset loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            resource: .encrypted(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    func withTrackerAdapters(_ trackerAdapters: [TrackerAdapter<M>]) -> Self {
        .init(id: id, resource: resource, metadata: metadata, configuration: configuration, trackerAdapters: trackerAdapters)
    }

    func withId(_ id: UUID) -> Self {
        .init(id: id, resource: resource, metadata: metadata, configuration: configuration, trackerAdapters: trackerAdapters)
    }

    func enable(for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func updateMetadata() {
        guard let metadata else { return }
        trackerAdapters.forEach { adapter in
            adapter.update(metadata: metadata)
        }
    }

    func disable() {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }

    func nowPlayingInfo() -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        if let metadata = metadata?.nowPlayingMetadata() {
            nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
            nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
            if let image = metadata.image {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            }
        }
        return nowPlayingInfo
    }

    func playerItem() -> AVPlayerItem {
        let item = resource.playerItem().withId(id)
        configuration(item)
        return item
    }
}

public extension Asset where M == Never {
    /// Returns a simple asset playable from a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    static func simple(
        url: URL,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            resource: .simple(url: url),
            metadata: nil,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// Returns an asset loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            resource: .custom(url: url, delegate: delegate),
            metadata: nil,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// Returns an encrypted asset loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            resource: .encrypted(url: url, delegate: delegate),
            metadata: nil,
            configuration: configuration,
            trackerAdapters: []
        )
    }
}

extension Asset {
    static var loading: Self {
        // Provides a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .init(
            id: UUID(),
            resource: .custom(url: URL(string: "pillarbox://loading.m3u8")!, delegate: LoadingResourceLoaderDelegate()),
            metadata: nil,
            configuration: { _ in },
            trackerAdapters: []
        )
    }

    static func failed(error: Error) -> Self {
        // Provides a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .init(
            id: UUID(),
            resource: .custom(url: URL(string: "pillarbox://failing.m3u8")!, delegate: FailedResourceLoaderDelegate(error: error)),
            metadata: nil,
            configuration: { _ in },
            trackerAdapters: []
        )
    }
}

extension AVPlayerItem {
    /// An identifier to identify player items delivered by the same data source.
    var id: UUID? {
        get {
            objc_getAssociatedObject(self, &kIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &kIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Assigns an identifier to identify player items delivered by the same data source.
    /// 
    /// - Parameter id: The id to assign.
    /// - Returns: The receiver with the id assigned to it.
    fileprivate func withId(_ id: UUID) -> AVPlayerItem {
        self.id = id
        return self
    }
}
