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

    @Published private(set) var content: AssetContent
    private let trackerAdapters: [any TrackerLifeCycle]

    let id = UUID()

    /// Creates the item from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public init<P, M>(
        publisher: P,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where P: Publisher, P.Output == Asset<M>, M: PlayerItemMetadata {
        let trackerAdapters = trackerAdapters.map { [id] adapter in
            adapter.withId(id)
        }
        self.trackerAdapters = trackerAdapters
        content = .loading(id: id)
        Publishers.PublishAndRepeat(onOutputFrom: Self.trigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            Publishers.CombineLatest(
                publisher,
                Just(trackerAdapters).setFailureType(to: P.Failure.self)
            )
            .map { asset, trackerAdapters in
                trackerAdapters.forEach { adapter in
                    adapter.updateMetadata(with: asset.metadata)
                }
                return AssetContent(
                    id: id,
                    resource: asset.resource,
                    metadata: .init(
                        items: asset.metadata.items(),
                        timedGroups: asset.metadata.timedGroups(),
                        chapterGroups: asset.metadata.chapterGroups()
                    ),
                    configuration: asset.configuration
                )
            }
            .catch { error in
                Just(.failing(id: id, error: error))
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
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<M>(
        asset: Asset<M>,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where M: PlayerItemMetadata {
        self.init(publisher: Just(asset), trackerAdapters: trackerAdapters)
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
        playerItem?.id == id
    }
}

extension PlayerItem {
    func enableTrackers(for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func updateTrackerProperties(_ properties: PlayerProperties) {
        trackerAdapters.forEach { adapter in
            adapter.updateProperties(with: properties)
        }
    }

    func disableTrackers() {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: PlayerItemMetadata {
        .init(
            asset: .simple(url: url, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: PlayerItemMetadata {
        .init(
            asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: PlayerItemMetadata {
        .init(
            asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
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
        trackerAdapters: [TrackerAdapter<Null>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .simple(url: url, configuration: configuration),
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
        trackerAdapters: [TrackerAdapter<Null>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, configuration: configuration),
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
        trackerAdapters: [TrackerAdapter<Null>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
            trackerAdapters: trackerAdapters
        )
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(content)"
    }
}
