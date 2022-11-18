//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

private var kIdKey: Void?

/// An item which stores its own custom resource loader delegate.
final class ResourceLoadedPlayerItem: AVPlayerItem {
    private let resourceLoaderDelegate: AVAssetResourceLoaderDelegate

    init(url: URL, resourceLoaderDelegate: AVAssetResourceLoaderDelegate, automaticallyLoadedAssetKeys: [String]?) {
        // swiftlint:disable:previous discouraged_optional_collection
        self.resourceLoaderDelegate = resourceLoaderDelegate
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}

final class ContentKeySessionPlayerItem: AVPlayerItem {
    private let contentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
    private let contentKeySessionDelegate: AVContentKeySessionDelegate

    init(url: URL, contentKeySessionDelegate: AVContentKeySessionDelegate, automaticallyLoadedAssetKeys: [String]?) {
        // swiftlint:disable:previous discouraged_optional_collection
        self.contentKeySessionDelegate = contentKeySessionDelegate
        contentKeySession.setDelegate(
            contentKeySessionDelegate,
            queue: DispatchQueue(label: "ch.srgssr.player.content_key_session")
        )

        let asset = AVURLAsset(url: url)
        contentKeySession.addContentKeyRecipient(asset)
        contentKeySession.processContentKeyRequest(withIdentifier: url.absoluteString, initializationData: nil)
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}

/// An item to be inserted into the player.
public final class PlayerItem: Equatable {
    @Published var playerItem = AVPlayerItem.loading
    @Published var chunkDuration: CMTime = .invalid

    private let id = UUID()

    /// Create the item from an `AVPlayerItem` publisher data source.
    public init<P>(publisher: P) where P: Publisher, P.Output == AVPlayerItem {
        publisher
            .catch { error in
                Just(AVPlayerItem.failing(error: error))
            }
            .prepend(AVPlayerItem.loading)
            .map { [id] item in
                item.withId(id)
            }
            .assign(to: &$playerItem)
        $playerItem
            .map { item in
                item.asset.propertyPublisher(.minimumTimeOffsetFromLive)
                    .map { CMTimeMultiplyByRatio($0, multiplier: 1, divisor: 3) }       // The minimum offset represents 3 chunks
                    .replaceError(with: .invalid)
                    .prepend(.invalid)
            }
            .switchToLatest()
            .removeDuplicates()
            .assign(to: &$chunkDuration)
    }

    /// Compare two items for equality.
    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    deinit {
        playerItem.cancelPendingSeeks()
        playerItem.asset.cancelLoading()
    }
}

public extension AVPlayerItem {
    /// An item which never finishes loading.
    static var loading: AVPlayerItem {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        let url = URL(string: "pillarbox://loading.m3u8")!
        return ResourceLoadedPlayerItem(url: url, resourceLoaderDelegate: LoadingResourceLoaderDelegate(), automaticallyLoadedAssetKeys: nil)
    }

    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play.
    convenience init(url: URL, automaticallyLoadedAssetKeys: [String]) {
        let asset = AVURLAsset(url: url)
        self.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }

    /// An item which immediately fails with a specific error.
    static func failing(error: Error) -> AVPlayerItem {
        // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
        let url = URL(string: "pillarbox://failing.m3u8")!
        return ResourceLoadedPlayerItem(url: url, resourceLoaderDelegate: FailingResourceLoaderDelegate(error: error), automaticallyLoadedAssetKeys: nil)
    }

    static func loading(
        url: URL,
        automaticallyLoadedAssetKeys: [String]? = nil
        // swiftlint:disable:previous discouraged_optional_collection
    ) -> AVPlayerItem {
        if let automaticallyLoadedAssetKeys {
            return AVPlayerItem(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        }
        else {
            return AVPlayerItem(url: url)
        }
    }

    /// An item which loads the specified URL (with an optionally associated resource loader delegate).
    static func loading(
        url: URL,
        resourceLoaderDelegate: AVAssetResourceLoaderDelegate,
        automaticallyLoadedAssetKeys: [String]? = nil
        // swiftlint:disable:previous discouraged_optional_collection
    ) -> AVPlayerItem {
        ResourceLoadedPlayerItem(
            url: url,
            resourceLoaderDelegate: resourceLoaderDelegate,
            automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys
        )
    }

    static func loading(
        url: URL,
        contentKeySessionDelegate: AVContentKeySessionDelegate,
        automaticallyLoadedAssetKeys: [String]? = nil
        // swiftlint:disable:previous discouraged_optional_collection
    ) -> AVPlayerItem {
        ContentKeySessionPlayerItem(
            url: url,
            contentKeySessionDelegate: contentKeySessionDelegate,
            automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys
        )
    }
}

public extension PlayerItem {
    /// Create a player item from a URL.
    /// - Parameters:
    ///   - urn: The URL to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    convenience init(url: URL, automaticallyLoadedAssetKeys: [String]? = nil) {
        // swiftlint:disable:previous discouraged_optional_collection
        let item = Self.item(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.init(item)
    }

    /// Create a player item from an asset.
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    convenience init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]? = nil) {
        // swiftlint:disable:previous discouraged_optional_collection
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.init(item)
    }

    /// Create a player item from a raw `AVFoundation` item.
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    convenience init(_ item: AVPlayerItem) {
        self.init(publisher: Just(item))
    }

    private static func item(url: URL, automaticallyLoadedAssetKeys: [String]?) -> AVPlayerItem {
        // swiftlint:disable:previous discouraged_optional_collection
        if let automaticallyLoadedAssetKeys {
            return AVPlayerItem(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        }
        else {
            return AVPlayerItem(url: url)
        }
    }
}

extension AVPlayerItem {
    /// An identifier to identify player items delivered by the same pipeline.
    var id: UUID? {
        get {
            objc_getAssociatedObject(self, &kIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &kIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Assign an identifier to help track items delivered by the same pipeline.
    /// - Parameter id: The id to assign.
    /// - Returns: The receiver with the id assigned to it.
    func withId(_ id: UUID) -> AVPlayerItem {
        self.id = id
        return self
    }
}
