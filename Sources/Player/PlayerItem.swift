//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

private var kIdKey: Void?

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

/// An item to be inserted into the player.
public final class PlayerItem: Equatable {
    @Published var playerItem: AVPlayerItem = LoadingPlayerItem()

    private let id = UUID()

    /// Create the item from an `AVPlayerItem` publisher data source.
    public init<P>(publisher: P) where P: Publisher, P.Output == AVPlayerItem {
        publisher
            .catch { error in
                Just(FailingPlayerItem(error: error))
            }
            .prepend(LoadingPlayerItem())
            .map { [id] item in
                item.withId(id)
            }
            .assign(to: &$playerItem)
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
    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play.
    convenience init(url: URL, automaticallyLoadedAssetKeys: [String]) {
        let asset = AVURLAsset(url: url)
        self.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
}

public extension PlayerItem {
    // swiftlint:disable discouraged_optional_collection

    /// Create a player item from a URL.
    /// - Parameters:
    ///   - urn: The URL to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    convenience init(url: URL, automaticallyLoadedAssetKeys: [String]? = nil) {
        let item = Self.item(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        self.init(item)
    }

    /// Create a player item from an asset.
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    convenience init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]? = nil) {
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
        if let automaticallyLoadedAssetKeys {
            return AVPlayerItem(url: url, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
        }
        else {
            return AVPlayerItem(url: url)
        }
    }

    // swiftlint:enable discouraged_optional_collection
}

extension AVPlayerItem {
    /// An identifier to identify player items delivered by the same pipeline.
    var id: UUID! {
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
