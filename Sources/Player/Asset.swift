//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer
import OSLog

private var kIdKey: Void?

private let kLogger = Logger(category: "Asset")

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
        // Provide same key as for a standard asset, see `AVPlayerItem.init(asset:)` documentation.
        super.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
    }
}

public typealias NowPlayingInfo = [String: Any]

/// An asset representing content to be played.
public struct Asset<M> {
    let id = UUID()

    private let type: `Type`
    private let metadata: M?
    private let configuration: (AVPlayerItem) -> Void

    /// A simple asset playable from a URL.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func simple(
        url: URL,
        metadata: M? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .simple(url: url),
            metadata: metadata,
            configuration: configuration
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
        metadata: M? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .custom(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
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
        metadata: M? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            type: .encrypted(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
        )
    }

    func playerItem() -> AVPlayerItem {
        let item = type.playerItem().withId(id)
        configuration(item)
        return item
    }

    func enable<T: PlayerItemTracker>(trackers: [TrackerAdapter<T, M>], for player: Player) {
        trackers.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func update<T: PlayerItemTracker>(trackers: [TrackerAdapter<T, M>]) {
        guard let metadata else { return }
        trackers.forEach { adapter in
            adapter.update(metadata: metadata)
        }
    }

    func disable<T: PlayerItemTracker>(trackers: [TrackerAdapter<T, M>]) {
        trackers.forEach { adapter in
            adapter.disable()
        }
    }

    public func nowPlayingInfo() -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
//        if let metadata {
//            nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
//            nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
//            nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
//            if let image = metadata.image {
//                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
//            }
//        }
        return nowPlayingInfo
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        playerItem?.id == id
    }
}

public extension Asset where M == Void {
    static func simple(
        url: URL,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .simple(url: url, metadata: (), configuration: configuration)
    }

    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .custom(url: url, delegate: delegate, metadata: (), configuration: configuration)
    }

    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .encrypted(url: url, delegate: delegate, metadata: (), configuration: configuration)
    }
}

public extension Asset {
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
#if targetEnvironment(simulator)
                kLogger.error("FairPlay-encrypted assets cannot be played in the simulator")
                return AVPlayerItem(url: url)
#else
                let asset = AVURLAsset(url: url)
                kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
                kContentKeySession.addContentKeyRecipient(asset)
                kContentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
                return AVPlayerItem(asset: asset)
#endif
            }
        }
    }
}

extension Asset {
    static var loading: Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .custom(url: URL(string: "pillarbox://loading.m3u8")!, delegate: LoadingResourceLoaderDelegate())
    }

    static func failed(error: Error) -> Self {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        .custom(url: URL(string: "pillarbox://failing.m3u8")!, delegate: FailedResourceLoaderDelegate(error: error))
    }
}

extension Sourceable {
    func matches(_ item: AVPlayerItem?) -> Bool {
        id == item?.id
    }

    func playerItem() -> AVPlayerItem {
        asset.playerItem().withId(id)
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
