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
public struct Asset<M: AssetMetadata>: Assetable {
    let id: UUID
    let type: AssetType
    private let metadata: M?
    private let configuration: (AVPlayerItem) -> Void
    private let trackerAdapters: [TrackerAdapter<M>]

    /// A simple asset playable from a URL.
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
            type: .simple(url: url),
            metadata: metadata,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// An asset loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            type: .custom(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// An encrypted asset loaded with a content key session.
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
            type: .encrypted(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    func withTrackerAdapters(_ trackerAdapters: [TrackerAdapter<M>]) -> Self {
        .init(id: id, type: type, metadata: metadata, configuration: configuration, trackerAdapters: trackerAdapters)
    }

    func withId(_ id: UUID) -> Self {
        .init(id: id, type: type, metadata: metadata, configuration: configuration, trackerAdapters: trackerAdapters)
    }

    func playerItem() -> AVPlayerItem {
        let item = type.playerItem().withId(id)
        configuration(item)
        return item
    }

    func enable(trackerAdapters: [TrackerAdapter<M>], for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func update(trackerAdapters: [TrackerAdapter<M>]) {
        guard let metadata else { return }
        trackerAdapters.forEach { adapter in
            adapter.update(metadata: metadata)
        }
    }

    func disable(trackerAdapters: [TrackerAdapter<M>]) {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }

    /// Returns metadata about the current asset to be displayed in the Control Center.
    public func nowPlayingInfo() -> NowPlaying.Info {
        var nowPlayingInfo = NowPlaying.Info()
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
}

extension Asset {
    func enable(for player: Player) {
        enable(trackerAdapters: trackerAdapters, for: player)
    }

    func updateMetadata() {
        update(trackerAdapters: trackerAdapters)
    }

    func disable() {
        disable(trackerAdapters: trackerAdapters)
    }
}

public extension Asset where M == EmptyAssetMetadata {
    /// A simple asset playable from a URL.
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
            type: .simple(url: url),
            metadata: nil,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// An asset loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            id: UUID(),
            type: .custom(url: url, delegate: delegate),
            metadata: nil,
            configuration: configuration,
            trackerAdapters: []
        )
    }

    /// An encrypted asset loaded with a content key session.
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
            type: .encrypted(url: url, delegate: delegate),
            metadata: nil,
            configuration: configuration,
            trackerAdapters: []
        )
    }
}

extension Asset {
    static var loading: Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .init(
            id: UUID(),
            type: .custom(url: URL(string: "pillarbox://loading.m3u8")!, delegate: LoadingResourceLoaderDelegate()),
            metadata: nil,
            configuration: { _ in },
            trackerAdapters: []
        )
    }

    static func failed(error: Error) -> Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .init(
            id: UUID(),
            type: .custom(url: URL(string: "pillarbox://failing.m3u8")!, delegate: FailedResourceLoaderDelegate(error: error)),
            metadata: nil,
            configuration: { _ in },
            trackerAdapters: []
        )
    }
}

extension Assetable {
    func matches(_ item: AVPlayerItem?) -> Bool {
        id == item?.id
    }
}

private extension AVPlayerItem {
    /// An identifier to identify player items delivered by the same data source.
    var id: UUID? {
        get {
            objc_getAssociatedObject(self, &kIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &kIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Assign an identifier to identify player items delivered by the same data source.
    /// - Parameter id: The id to assign.
    /// - Returns: The receiver with the id assigned to it.
    func withId(_ id: UUID) -> AVPlayerItem {
        self.id = id
        return self
    }
}
