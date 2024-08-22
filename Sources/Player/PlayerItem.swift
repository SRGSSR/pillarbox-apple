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
/// Convenience initializers are provided for different types of assets:
///
/// - Simple assets which can be played from a simple URL.
/// - Custom assets which require custom resource loading.
/// - Encrypted assets which require a FairPlay content key session.
public final class PlayerItem: Hashable {
    private static let trigger = Trigger()

    @Published private(set) var content: AssetContent
    private let trackerAdapters: [any PlayerItemTracking]

    let id = UUID()

    /// The source attached to the item, if any.
    public let source: Any?

    /// Creates an item loaded from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    public convenience init<P, M>(
        publisher: P,
        trackerAdapters: [TrackerAdapter<M>] = [],
        source: Any? = nil
    ) where P: Publisher, P.Output == Asset<M>, M: AssetMetadata {
        self.init(
            publisher: publisher,
            metadataMapper: { $0.playerMetadata },
            trackerAdapters: trackerAdapters,
            source: source
        )
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    public convenience init<M>(
        asset: Asset<M>,
        trackerAdapters: [TrackerAdapter<M>] = [],
        source: Any? = nil
    ) where M: AssetMetadata {
        self.init(publisher: Just(asset), trackerAdapters: trackerAdapters, source: source)
    }

    /// Creates an item loaded from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    public convenience init<P>(
        publisher: P,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        source: Any? = nil
    ) where P: Publisher, P.Output == Asset<Void> {
        self.init(
            publisher: publisher,
            metadataMapper: { _ in .empty },
            trackerAdapters: trackerAdapters,
            source: source
        )
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    public convenience init(
        asset: Asset<Void>,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        source: Any? = nil
    ) {
        self.init(publisher: Just(asset), trackerAdapters: trackerAdapters, source: source)
    }

    private init<P, M>(
        publisher: P,
        metadataMapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>],
        source: Any? = nil
    ) where P: Publisher, P.Output == Asset<M> {
        self.trackerAdapters = trackerAdapters
        self.source = source
        content = .loading(id: id)
        Publishers.PublishAndRepeat(onOutputFrom: Self.trigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            publisher
                .handleEvents(receiveOutput: { asset in
                    // swiftlint:disable:previous trailing_closure
                    trackerAdapters.forEach { adapter in
                        adapter.updateMetadata(to: asset.metadata)
                    }
                })
                .map { asset in
                    Publishers.CombineLatest(
                        Just(asset),
                        metadataMapper(asset.metadata).playerMetadataPublisher()
                    )
                }
                .switchToLatest()
                .map { asset, metadata in
                    AssetContent(id: id, resource: asset.resource, metadata: metadata, configuration: asset.configuration)
                }
                .catch { error in
                    Just(.failing(id: id, error: error))
                }
        }
        .wait(untilOutputFrom: Self.trigger.signal(activatedBy: TriggerId.load(id)))
        .receive(on: DispatchQueue.main)
        .assign(to: &$content)
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    static func load(for id: UUID) {
        trigger.activate(for: TriggerId.load(id))
    }

    static func reload(for id: UUID) {
        trigger.activate(for: TriggerId.reset(id))
        trigger.activate(for: TriggerId.load(id))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        playerItem?.id == id
    }
}

extension PlayerItem {
    private func trackerAdapters(matchingBehavior behavior: TrackingBehavior) -> [PlayerItemTracking] {
        trackerAdapters.filter { $0.behavior == behavior }
    }

    func enableTrackers(matchingBehavior behavior: TrackingBehavior, for player: AVPlayer) {
        trackerAdapters(matchingBehavior: behavior).forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func updateTrackersProperties(matchingBehavior behavior: TrackingBehavior, to properties: PlayerProperties) {
        trackerAdapters(matchingBehavior: behavior).forEach { adapter in
            adapter.updateProperties(to: properties)
        }
    }

    func updateTrackersMetricEvents(matchingBehavior behavior: TrackingBehavior, to events: [MetricEvent]) {
        trackerAdapters(matchingBehavior: behavior).forEach { adapter in
            adapter.updateMetricEvents(to: events)
        }
    }

    func disableTrackers(matchingBehavior behavior: TrackingBehavior, with properties: PlayerProperties) {
        trackerAdapters(matchingBehavior: behavior).forEach { adapter in
            adapter.disable(with: properties)
        }
    }

    func sessionIdentifiers<T>(trackedBy type: T.Type) -> [String] where T: PlayerItemTracker {
        trackerAdapters.compactMap(\.registration)
            .filter { $0.type == type }
            .map(\.sessionIdentifier)
            .sorted()
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        source: Any? = nil,
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .simple(url: url, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters,
            source: source
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        source: Any? = nil,
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters,
            source: source
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        source: Any? = nil,
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            trackerAdapters: trackerAdapters,
            source: source
        )
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: Any useful information that describes the source of the content.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple(
        url: URL,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        source: Any? = nil,
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .simple(url: url, configuration: configuration),
            trackerAdapters: trackerAdapters,
            source: source
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: A description of the source of the content.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        source: Any? = nil,
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, configuration: configuration),
            trackerAdapters: trackerAdapters,
            source: source
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - source: A description of the source of the content.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        source: Any? = nil,
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
            trackerAdapters: trackerAdapters,
            source: source
        )
    }
}

extension PlayerItem {
    func metadataPublisher() -> AnyPublisher<PlayerMetadata, Never> {
        $content
            .map(\.metadata)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(id)"
    }
}
