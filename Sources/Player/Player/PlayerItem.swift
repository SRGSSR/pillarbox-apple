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
    private let queue = DispatchQueue(label: "ch.srgssr.player-item")

    let id = UUID()

    /// Creates an item loaded using an ``AssetLoader``.
    ///
    /// - Parameters:
    ///   - assetLoaderType: The asset loader type.
    ///   - input: The input expected by the asset loader.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<A>(assetLoaderType: A.Type, input: A.Input, trackerAdapters: [TrackerAdapter<A.Metadata>] = []) where A: AssetLoader {
        self.init(
            metadataPublisher: assetLoaderType.metadataPublisher(for: input),
            metadataMapper: { assetLoaderType.playerMetadata(from: $0) },
            assetProvider: { assetLoaderType.asset(input: input, metadata: $0) },
            trackerAdapters: trackerAdapters
        )
    }

#if DEBUG
    convenience init?<S>(download: Download, store: S, allowsPartial: Bool, trackerAdapters: [TrackerAdapter<S.Metadata>]) where S: DownloadStore {
        guard let record = store.downloadRecord(forId: download.id),
              let metadata = record.metadata,
              let fileUrl = download.fileUrl(allowsPartial: allowsPartial) else {
            return nil
        }
        let storeType = type(of: store)
        self.init(
            metadataPublisher: Just(metadata),
            metadataMapper: { storeType.playerMetadata(from: $0) },
            assetProvider: { storeType.asset(fileUrl: fileUrl, input: record.input, metadata: $0) },
            trackerAdapters: trackerAdapters
        )
    }
#endif

    private init<P, M>(
        metadataPublisher: P,
        metadataMapper: @escaping (M) -> PlayerMetadata,
        assetProvider: @escaping (M) -> Asset,
        trackerAdapters: [TrackerAdapter<M>]
    ) where P: Publisher, P.Output == M {
        self.trackerAdapters = trackerAdapters
        self.content = .loading(id: id)

        Publishers.PublishAndRepeat(onOutputFrom: Self.trigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            metadataPublisher
                .handleEvents(receiveOutput: { metadata in
                    trackerAdapters.forEach { adapter in
                        adapter.updateMetadata(to: metadata)
                    }
                }, receiveCompletion: nil)
                .withInterval(clock: .suspending)
                .map { metadata, interval in
                    Publishers.CombineLatest3(
                        Just(assetProvider(metadata)),
                        metadataMapper(metadata).playerMetadataPublisher(),
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
    /// Returns a simple playable item.
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
            assetLoaderType: SimpleAssetLoader.self,
            input: .init(url: url, metadata: metadata, configuration: configuration),
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
