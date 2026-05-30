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

    let id = UUID()

    private let trackerAdapters: [any PlayerItemTracking]
    private let queue = DispatchQueue(label: "ch.srgssr.player-item")

    @Published private(set) var content: AssetContent

    /// Creates an item loaded using an ``AssetLoader``.
    ///
    /// - Parameters:
    ///   - assetLoaderType: The asset loader type.
    ///   - input: The input expected by the asset loader.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public init<A>(assetLoaderType: A.Type, input: A.Input, trackerAdapters: [TrackerAdapter<A.Metadata>] = []) where A: AssetLoader {
        self.trackerAdapters = trackerAdapters
        self.content = .loading(id: id)
        Publishers.PublishAndRepeat(onOutputFrom: Self.trigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            assetLoaderType.metadataPublisher(for: input)
                .handleEvents(receiveOutput: { metadata in
                    trackerAdapters.forEach { adapter in
                        adapter.updateMetadata(to: metadata)
                    }
                }, receiveCompletion: nil)
                .withInterval(clock: .suspending)
                .map { metadata, interval in
                    Publishers.CombineLatest3(
                        Just(assetLoaderType.asset(input: input, metadata: metadata)),
                        assetLoaderType.playerMetadata(input: input, metadata: metadata).playerMetadataPublisher(),
                        Just(interval)
                    )
                }
                .switchToLatest()
                .map { asset, metadata, interval in
                    .loaded(
                        id: id,
                        resource: asset.resource,
                        metadata: metadata,
                        configuration: asset.configuration,
                        serviceInterval: interval
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

    // swiftlint:disable:next missing_docs
    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs.id == rhs.id
    }

    static func load(for id: UUID) {
        trigger.activate(for: TriggerId.load(id))
    }

    static func reload(for id: UUID) {
        trigger.activate(for: TriggerId.reset(id))
        trigger.activate(for: TriggerId.load(id))
    }

    // swiftlint:disable:next missing_docs
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        playerItem?.id == id
    }
}

public extension PlayerItem {
    /// Creates a player item from an ``Asset`` and standard player metadata.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - metadata: The metadata associated with the item.
    ///   - mapper: A closure that maps an item metadata to player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    convenience init<M>(
        asset: Asset,
        metadata: M,
        mapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) {
        self.init(
            assetLoaderType: ImmediateAssetLoader.self,
            input: .init(asset: asset, metadata: metadata, mapper: mapper),
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates an simple player item with standard player metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - mapper: A closure that maps an item metadata to player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M,
        mapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        self.init(
            asset: .simple(url: url, configuration: configuration),
            metadata: metadata,
            mapper: mapper,
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates an custom player item with standard player metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - mapper: A closure that maps an item metadata to player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        mapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, configuration: configuration),
            metadata: metadata,
            mapper: mapper,
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates an encrypted player item with standard player metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - mapper: A closure that maps an item metadata to player metadata.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        mapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
            metadata: metadata,
            mapper: mapper,
            trackerAdapters: trackerAdapters
        )
    }
}

public extension PlayerItem {
    /// Creates a player item from an ``Asset`` and standard player metadata.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    convenience init(
        asset: Asset,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = []
    ) {
        self.init(asset: asset, metadata: metadata, mapper: \.self, trackerAdapters: trackerAdapters)
    }

    /// Creates an simple player item with standard player metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple(
        url: URL,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        self.init(
            asset: .simple(url: url, configuration: configuration),
            metadata: metadata,
            mapper: \.self,
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates an custom player item with standard player metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            asset: .custom(url: url, delegate: delegate, configuration: configuration),
            metadata: metadata,
            mapper: \.self,
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates an encrypted player item with standard player metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: PlayerMetadata = .empty,
        trackerAdapters: [TrackerAdapter<PlayerMetadata>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
            metadata: metadata,
            mapper: \.self,
            trackerAdapters: trackerAdapters
        )
    }
}

extension PlayerItem {
    private func trackerAdapters(matchingBehavior behavior: TrackingBehavior) -> [PlayerItemTracking] {
        trackerAdapters.filter { $0.behavior == behavior }
    }

    func enableTrackers(matchingBehavior behavior: TrackingBehavior, for player: AVPlayer) {
        queue.async {
            self.trackerAdapters(matchingBehavior: behavior).forEach { adapter in
                adapter.enable(for: player)
            }
        }
    }

    func updateTrackersProperties(matchingBehavior behavior: TrackingBehavior, to properties: PlayerProperties) {
        let time = properties.time()
        queue.async {
            let adapters = self.trackerAdapters(matchingBehavior: behavior)
            guard !adapters.isEmpty else { return }
            let trackerProperties = TrackerProperties(
                playerProperties: properties,
                time: time,
                date: properties.date(at: time),
                metrics: properties.metrics()
            )
            adapters.forEach { adapter in
                adapter.updateProperties(to: trackerProperties)
            }
        }
    }

    func updateTrackersMetricEvents(matchingBehavior behavior: TrackingBehavior, to events: [MetricEvent]) {
        queue.async {
            self.trackerAdapters(matchingBehavior: behavior).forEach { adapter in
                adapter.updateMetricEvents(to: events)
            }
        }
    }

    func disableTrackers(matchingBehavior behavior: TrackingBehavior, with properties: PlayerProperties) {
        let time = properties.time()
        queue.async {
            let adapters = self.trackerAdapters(matchingBehavior: behavior)
            guard !adapters.isEmpty else { return }
            let trackerProperties = TrackerProperties(
                playerProperties: properties,
                time: time,
                date: properties.date(at: time),
                metrics: properties.metrics()
            )
            adapters.forEach { adapter in
                adapter.disable(with: trackerProperties)
            }
        }
    }

    func sessionIdentifiers<T>(trackedBy type: T.Type) -> [String] where T: PlayerItemTracker {
        trackerAdapters.compactMap(\.registration)
            .filter { $0.type == type }
            .map(\.sessionIdentifier)
            .sorted()
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
    // swiftlint:disable:next missing_docs
    public var debugDescription: String {
        "\(id)"
    }
}
