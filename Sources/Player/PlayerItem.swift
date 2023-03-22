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
    public init<P, T, M>(publisher: P, trackers: [TrackerAdapter<T, M>]) where P: Publisher, M: AssetMetadata, T: PlayerItemTracker, P.Output == Asset<M> {
        source = Source(id: id, asset: .loading, trackers: trackers)
        publisher
            .catch { error in
                Just(.failed(error: error))
            }
            .map { [id] asset in
                Source(id: id, asset: asset, trackers: trackers)
            }
            // Mitigate instabilities arising when publisher involves `URLSession` publishers, see issue #206.
            .receiveOnMainThread()
            .assign(to: &$source)
    }

    public convenience init<P, M>(publisher: P) where P: Publisher, M: AssetMetadata, P.Output == Asset<M> {
        self.init(publisher: publisher, trackers: [TrackerAdapter<EmptyTracker, M>]())
    }

    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public convenience init<T, M>(asset: Asset<M>, trackers: [TrackerAdapter<T, M>]) where T: PlayerItemTracker, M: AssetMetadata {
        self.init(publisher: Just(asset), trackers: trackers)
    }

    public convenience init<M>(asset: Asset<M>) where M: AssetMetadata {
        self.init(publisher: Just(asset), trackers: [TrackerAdapter<EmptyTracker, M>]())
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
    static func simple<T, M>(
        url: URL,
        metadata: M? = nil,
        trackers: [TrackerAdapter<T, M>],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where T: PlayerItemTracker, M: AssetMetadata {
        .init(asset: .simple(url: url, metadata: metadata, configuration: configuration), trackers: trackers)
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
    static func custom<T, M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M? = nil,
        trackers: [TrackerAdapter<T, M>],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where T: PlayerItemTracker, M: AssetMetadata {
        .init(asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration), trackers: trackers)
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
    static func encrypted<T, M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M? = nil,
        trackers: [TrackerAdapter<T, M>],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where T: PlayerItemTracker, M: AssetMetadata {
        .init(asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration), trackers: trackers)
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

private class EmptyTracker: PlayerItemTracker {
    required init() {}
    func enable(for player: Player) {}
    func disable() {}
    func update(with metadata: Void) {}
}
