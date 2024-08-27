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
    ///
    /// You can optionally attach information about the source that the item was created from at construction time
    /// so that you can access it at a later time if needed. Some APIs, e.g. ``Playlist``, will also automatically
    /// resurface attached source information in cases it can be helpful.
    public let source: Any?

    /// Creates an item loaded from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<P, M>(
        publisher: P,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where P: Publisher, P.Output == Asset<M>, M: AssetMetadata {
        self.init(
            publisher: publisher,
            source: source,
            metadataMapper: { $0.playerMetadata },
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<M>(
        asset: Asset<M>,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where M: AssetMetadata {
        self.init(publisher: Just(asset), source: source, trackerAdapters: trackerAdapters)
    }

    /// Creates an item loaded from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<P>(
        publisher: P,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<Void>] = []
    ) where P: Publisher, P.Output == Asset<Void> {
        self.init(
            publisher: publisher,
            source: source,
            metadataMapper: { _ in .empty },
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init(
        asset: Asset<Void>,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<Void>] = []
    ) {
        self.init(publisher: Just(asset), source: source, trackerAdapters: trackerAdapters)
    }

    private init<P, M>(
        publisher: P,
        source: Any? = nil,
        metadataMapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>]
    ) where P: Publisher, P.Output == Asset<M> {
        self.trackerAdapters = trackerAdapters
        self.source = source
        content = .loading(id: id)
        Publishers.PublishAndRepeat(onOutputFrom: Self.trigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            Publishers.CombineLatest(
                publisher,
                Just(Date()).setFailureType(to: P.Failure.self)
            )
            .handleEvents(receiveOutput: { asset, _ in
                // swiftlint:disable:previous trailing_closure
                trackerAdapters.forEach { adapter in
                    adapter.updateMetadata(to: asset.metadata)
                }
            })
            .map { asset, startDate in
                Publishers.CombineLatest3(
                    Just(asset),
                    metadataMapper(asset.metadata).playerMetadataPublisher(),
                    Just(DateInterval(start: startDate, end: Date()))
                )
            }
            .switchToLatest()
            .map { asset, metadata, dateInterval in
                AssetContent(
                    id: id,
                    resource: asset.resource,
                    metadata: metadata,
                    configuration: asset.configuration,
                    dateInterval: dateInterval
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
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .simple(url: url, metadata: metadata, configuration: configuration),
            source: source,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            source: source,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            source: source,
            trackerAdapters: trackerAdapters
        )
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple(
        url: URL,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .simple(url: url, configuration: configuration),
            source: source,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, configuration: configuration),
            source: source,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - source: Arbitrary information that describes the source which the item was created from.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        source: Any? = nil,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
            source: source,
            trackerAdapters: trackerAdapters
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
