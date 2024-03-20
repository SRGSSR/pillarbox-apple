//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

private enum TriggerId: Hashable {
    case load(UUID)
    case reset(UUID)
}

/// An item that can be inserted into a ``Player`` for playback.
///
/// Convenience initialization methods are provided for different types of assets:
///
/// - Simple assets which can be played from a simple URL.
/// - Custom assets which require custom resource loading.
/// - Encrypted assets which require a FairPlay content key session.
public final class PlayerItem: Equatable {
    private static let trigger = Trigger()

    @Published private(set) var content: any PlayerItemContent

    let id = UUID()

    /// Creates the item from an ``Asset`` publisher data source.
    public init<P, M>(
        publisher: P,
        metadataAdapter: MetadataAdapter<M> = .none(),
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where P: Publisher, P.Output == Asset<M> {
        let trackerAdapters = trackerAdapters.map { [id] adapter in
            adapter.withId(id)
        }
        content = ResourceContent(resource: .loading, id: id, metadataAdapter: metadataAdapter, trackerAdapters: trackerAdapters)
        Publishers.PublishAndRepeat(onOutputFrom: Self.trigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            publisher
                .map { asset in
                    AssetContent(asset: asset, id: id, metadataAdapter: metadataAdapter, trackerAdapters: trackerAdapters)
                }
                .catch { error in
                    Just(ResourceContent(resource: .failing(error: error), id: id, metadataAdapter: metadataAdapter, trackerAdapters: trackerAdapters))
                }
        }
        .wait(untilOutputFrom: Self.trigger.signal(activatedBy: TriggerId.load(id)))
        .receive(on: DispatchQueue.main)
        .assign(to: &$content)
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - metadataAdapter: A `MetadataAdapter` converting item metadata into player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<M>(asset: Asset<M>, metadataAdapter: MetadataAdapter<M> = .none(), trackerAdapters: [TrackerAdapter<M>] = []) {
        self.init(publisher: Just(asset), metadataAdapter: metadataAdapter, trackerAdapters: trackerAdapters)
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    static func load(for id: UUID) {
        Self.trigger.activate(for: TriggerId.load(id))
    }

    static func reload(for id: UUID) {
        Self.trigger.activate(for: TriggerId.reset(id))
        Self.trigger.activate(for: TriggerId.load(id))
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        content.matches(playerItem)
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - metadataAdapter: A `MetadataAdapter` converting item metadata into player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M,
        metadataAdapter: MetadataAdapter<M> = .none(),
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .simple(url: url, metadata: metadata, configuration: configuration),
            metadataAdapter: metadataAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - metadataAdapter: A `MetadataAdapter` converting item metadata into player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        metadataAdapter: MetadataAdapter<M> = .none(),
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            metadataAdapter: metadataAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - metadataAdapter: A `MetadataAdapter` converting item metadata into player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        metadataAdapter: MetadataAdapter<M> = .none(),
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            metadataAdapter: metadataAdapter,
            trackerAdapters: trackerAdapters
        )
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple(
        url: URL,
        metadataAdapter: MetadataAdapter<Void> = .none(),
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .simple(url: url, configuration: configuration),
            metadataAdapter: metadataAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadataAdapter: MetadataAdapter<Void> = .none(),
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, configuration: configuration),
            metadataAdapter: metadataAdapter,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadataAdapter: MetadataAdapter<Void> = .none(),
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
            metadataAdapter: metadataAdapter,
            trackerAdapters: trackerAdapters
        )
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(content)"
    }
}
