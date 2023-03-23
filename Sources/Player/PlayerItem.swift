//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core

/// An item to be inserted into the player.
public final class PlayerItem: Equatable {
    @Published private(set) var source: any Sourceable

    private let id = UUID()

    /// Create the item from an `Asset` publisher data source.
    public init<P, M>(publisher: P, trackerAdapters: [TrackerAdapter<M>]) where P: Publisher, M: AssetMetadata, P.Output == Asset<M> {
        source = Source(id: id, asset: .loading, trackerAdapters: trackerAdapters)
        publisher
            .catch { error in
                Just(.failed(error: error))
            }
            .map { [id] asset in
                Source(id: id, asset: asset, trackerAdapters: trackerAdapters)
            }
            // Mitigate instabilities arising when publisher involves `URLSession` publishers, see issue #206.
            .receiveOnMainThread()
            .assign(to: &$source)
    }

    public convenience init<P, M>(publisher: P) where P: Publisher, M: AssetMetadata, P.Output == Asset<M> {
        self.init(publisher: publisher, trackerAdapters: [TrackerAdapter<M>]())
    }

    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public convenience init<M>(asset: Asset<M>, trackerAdapters: [TrackerAdapter<M>]) where M: AssetMetadata {
        self.init(publisher: Just(asset), trackerAdapters: trackerAdapters)
    }

    public convenience init<M>(asset: Asset<M>) where M: AssetMetadata {
        self.init(publisher: Just(asset), trackerAdapters: [TrackerAdapter<M>]())
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        source.matches(playerItem)
    }
}

public extension PlayerItem {
    /// A simple playable item.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M? = nil,
        trackerAdapters: [TrackerAdapter<M>],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .simple(url: url, metadata: metadata, configuration: configuration), trackerAdapters: trackerAdapters)
    }

    static func simple<M>(
        url: URL,
        metadata: M? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .simple(url: url, metadata: metadata, configuration: configuration))
    }

    /// An item loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M? = nil,
        trackerAdapters: [TrackerAdapter<M>],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration), trackerAdapters: trackerAdapters)
    }

    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration))
    }

    /// An encrypted item loaded with a content key session.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M? = nil,
        trackerAdapters: [TrackerAdapter<M>],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration), trackerAdapters: trackerAdapters)
    }

    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M? = nil,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration))
    }
}

public extension PlayerItem {
    static func simple(
        url: URL,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .simple(url: url, metadata: EmptyAssetMetadata(), configuration: configuration))
    }

    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .custom(url: url, delegate: delegate, metadata: EmptyAssetMetadata(), configuration: configuration))
    }

    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .encrypted(url: url, delegate: delegate, metadata: EmptyAssetMetadata(), configuration: configuration))
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(source)"
    }
}

private final class EmptyTracker: PlayerItemTracker {
    func enable(for player: Player) {}
    func disable() {}
    func update(metadata: Void) {}
}
