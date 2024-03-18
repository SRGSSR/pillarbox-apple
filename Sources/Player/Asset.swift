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
public struct Asset<M>: Assetable {
    let id: UUID
    let resource: Resource
    private let metadata: M?
    private let configuration: (AVPlayerItem) -> Void
    private let mapperAdapter: MapperAdapter<M>?
    private let trackerAdapters: [TrackerAdapter<M>]

    init(
        id: UUID,
        resource: Resource,
        metadata: M?,
        configuration: @escaping (AVPlayerItem) -> Void,
        mapperAdapter: MapperAdapter<M>?,
        trackerAdapters: [TrackerAdapter<M>]
    ) {
        self.id = id
        self.resource = resource
        self.metadata = metadata
        self.configuration = configuration
        self.mapperAdapter = mapperAdapter
        self.trackerAdapters = trackerAdapters.map { $0.withId(id) }
    }

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
            mapperAdapter: nil,
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
            mapperAdapter: nil,
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
            mapperAdapter: nil,
            trackerAdapters: []
        )
    }

    func withMapperAdapter(_ mapperAdapter: MapperAdapter<M>) -> Self {
        .init(
            id: id,
            resource: resource,
            metadata: metadata,
            configuration: configuration,
            mapperAdapter: mapperAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    func withTrackerAdapters(_ trackerAdapters: [TrackerAdapter<M>]) -> Self {
        .init(
            id: id,
            resource: resource,
            metadata: metadata,
            configuration: configuration,
            mapperAdapter: mapperAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    func withId(_ id: UUID) -> Self {
        .init(
            id: id,
            resource: resource,
            metadata: metadata,
            configuration: configuration,
            mapperAdapter: mapperAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    func enable(for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func updateMetadata() {
        guard let metadata else { return }
        mapperAdapter?.update(metadata: metadata)
        trackerAdapters.forEach { adapter in
            adapter.update(metadata: metadata)
        }
    }

    func disable() {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }

    func playerItem(reload: Bool) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configuration(item)
            update(item: item)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configuration(item)
            update(item: item)
            PlayerItem.load(for: id)
            return item
        }
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        mapperAdapter?.mediaItemInfo(with: error) ?? .init()
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = mapperAdapter?.metadataItems() ?? []
        // FIXME: On tvOS set navigation markers
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
            mapperAdapter: nil,
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
            mapperAdapter: nil,
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
            mapperAdapter: nil,
            trackerAdapters: []
        )
    }
}

extension Asset {
    static var loading: Self {
        .init(id: UUID(), resource: .loading, metadata: nil, configuration: { _ in }, mapperAdapter: nil, trackerAdapters: [])
    }

    static func failed(error: Error) -> Self {
        .init(id: UUID(), resource: .failing(error: error), metadata: nil, configuration: { _ in }, mapperAdapter: nil, trackerAdapters: [])
    }
}

extension AVPlayerItem {
    /// An identifier for player items delivered by the same data source.
    var id: UUID? {
        get {
            objc_getAssociatedObject(self, &kIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &kIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Assigns an identifier for player items delivered by the same data source.
    /// 
    /// - Parameter id: The id to assign.
    /// - Returns: The receiver with the id assigned to it.
    fileprivate func withId(_ id: UUID) -> AVPlayerItem {
        self.id = id
        return self
    }
}
