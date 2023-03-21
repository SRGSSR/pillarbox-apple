//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core

private var kIdKey: Void?

/// An item to be inserted into the player.
public final class PlayerItem: Equatable {
    @Published private(set) var source: Source

    private let trackers: [PlayerItemTracker]
    private let id = UUID()

    /// Create the item from an `Asset` publisher data source.
    public init<P>(publisher: P, trackers: [PlayerItemTracker.Type] = []) where P: Publisher, P.Output == Asset {
        source = Source(id: id, asset: .loading)
        self.trackers = Self.trackers(trackers)
        publisher
            .catch { error in
                Just(.failed(error: error))
            }
            .map { [id] asset in
                Source(id: id, asset: asset)
            }
            // Mitigate instabilities arising when publisher involves `URLSession` publishers, see issue #206.
            .receiveOnMainThread()
            .assign(to: &$source)
    }

    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public convenience init(asset: Asset, trackers: [PlayerItemTracker.Type] = []) {
        self.init(publisher: Just(asset), trackers: trackers)
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        playerItem?.id == id
    }
}

public extension PlayerItem {
    /// A simple playable item.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple(
        url: URL,
        metadata: Asset.Metadata? = nil,
        trackers: [PlayerItemTracker.Type] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .simple(url: url, metadata: metadata, configuration: configuration), trackers: trackers)
    }

    /// An item loaded with custom resource loading. The scheme of the URL to be played has to be recognized by
    /// the associated resource loader delegate.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: Asset.Metadata? = nil,
        trackers: [PlayerItemTracker.Type] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration), trackers: trackers)
    }

    /// An encrypted item loaded with a content key session.
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: Asset.Metadata? = nil,
        trackers: [PlayerItemTracker.Type] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration), trackers: trackers)
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(source)"
    }
}

extension PlayerItem {
    static func trackers(_ trackers: [PlayerItemTracker.Type]) -> [PlayerItemTracker] {
        trackers.map { type in
            type.init()
        }
    }

    func enableTrackers(with player: Player) {
        trackers.forEach { $0.enable(for: player) }
    }

    func disableTrackers() {
        trackers.forEach { $0.disable() }
    }
}

extension Source {
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
