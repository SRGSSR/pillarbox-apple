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
public final class PlayerItem: Identifiable {
    private static let trigger = Trigger()

    /// A unique identifier.
    public let id = UUID()

    private let trackerAdapters: [any PlayerItemTracking]
    private let queue = DispatchQueue(label: "ch.srgssr.player-item")

    @Published private(set) var content: AssetContent

    /// Creates an item loaded using an ``AssetLoader``.
    ///
    /// - Parameters:
    ///   - assetLoaderType: The asset loader type.
    ///   - input: The input expected by the asset loader.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public init<Loader>(assetLoaderType: Loader.Type, input: Loader.Input, trackerAdapters: [TrackerAdapter<Loader.Metadata>] = []) where Loader: AssetLoader {
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
                        Just(assetLoaderType.asset(from: input, metadata: metadata)),
                        assetLoaderType.playerMetadata(from: input, metadata: metadata).lazyPlayerMetadataPublisher(),
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

    convenience init<CustomData>(
        asset: Asset,
        metadata: AssetMetadata<CustomData>,
        trackerAdapters: [TrackerAdapter<AssetMetadata<CustomData>>]
    ) {
        self.init(
            assetLoaderType: DirectAssetLoader.self,
            input: .init(asset: asset, metadata: metadata),
            trackerAdapters: trackerAdapters
        )
    }

    static func load(for id: UUID) {
        trigger.activate(for: TriggerId.load(id))
    }

    static func reload(for id: UUID) {
        trigger.activate(for: TriggerId.reset(id))
        trigger.activate(for: TriggerId.load(id))
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        playerItem?.id == id
    }
}

// TODO: Use the ID instead of reference equality when the feedback (https://github.com/SRGSSR/apple-bug-reports/blob/main/FB23923342/Report.md)
// is resolved by Apple.
extension PlayerItem: Hashable {
    // swiftlint:disable:next missing_docs
    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    // swiftlint:disable:next missing_docs
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public extension PlayerItem {
    private convenience init<Provider>(
        assetProviderType: Provider.Type,
        input: URLInput<Provider.CustomData>,
        trackerAdapters: [TrackerAdapter<AssetMetadata<Provider.CustomData>>]
    ) where Provider: URLOnlineAssetProvider {
        self.init(assetLoaderType: URLAssetLoader<Provider>.self, input: input, trackerAdapters: trackerAdapters)
    }

    /// Creates an simple player item with asset metadata.
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
        // TODO: Configuration?? Provided via URLInput?
        self.init(assetProviderType: URLEmptyAssetProvider.self, input: .init(url: url, metadata: metadata), trackerAdapters: trackerAdapters)
    }

    /// Creates a custom player item with asset metadata.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<Provider>(
        assetProviderType: Provider.Type,
        url: URL,
        metadata: AssetMetadata<Provider.CustomData>,
        trackerAdapters: [TrackerAdapter<AssetMetadata<Provider.CustomData>>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self where Provider: URLOnlineAssetProvider {
        // TODO: Configuration?? Provided via URLInput?
        self.init(assetProviderType: assetProviderType, input: .init(url: url, metadata: metadata), trackerAdapters: trackerAdapters)
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
