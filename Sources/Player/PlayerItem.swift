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

    /// Creates an item loaded from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<P, M>(
        publisher: P,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where P: Publisher, P.Output == Asset<M>, M: AssetMetadata {
        self.init(
            publisher: publisher,
            metadataMapper: { $0.playerMetadata },
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<M>(
        asset: Asset<M>,
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where M: AssetMetadata {
        self.init(publisher: Just(asset), trackerAdapters: trackerAdapters)
    }

    /// Creates an item loaded from an ``Asset`` publisher data source.
    ///
    /// - Parameters:
    ///   - publisher: The asset publisher.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init<P>(
        publisher: P,
        trackerAdapters: [TrackerAdapter<Void>] = []
    ) where P: Publisher, P.Output == Asset<Void> {
        self.init(
            publisher: publisher,
            metadataMapper: { _ in .empty },
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates a player item from an ``Asset``.
    ///
    /// - Parameters:
    ///   - asset: The asset to play.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    public convenience init(
        asset: Asset<Void>,
        trackerAdapters: [TrackerAdapter<Void>] = []
    ) {
        self.init(publisher: Just(asset), trackerAdapters: trackerAdapters)
    }

    private init<P, M>(
        publisher: P,
        metadataMapper: @escaping (M) -> PlayerMetadata,
        trackerAdapters: [TrackerAdapter<M>]
    ) where P: Publisher, P.Output == Asset<M> {
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
                return Publishers.CombineLatest(
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
    func enableTrackers(for player: AVPlayer) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func updateTrackerProperties(with properties: PlayerProperties) {
        trackerAdapters.forEach { adapter in
            adapter.updateProperties(with: properties)
        }
    }

    func receiveTrackerMetricEvent(_ event: MetricEvent) {
        trackerAdapters.forEach { adapter in
            adapter.receiveMetricEvent(event)
        }
    }

    func disableTrackers(with properties: PlayerProperties) {
        trackerAdapters.forEach { adapter in
            adapter.disable(with: properties)
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
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
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
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
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
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self where M: AssetMetadata {
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
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func simple(
        url: URL,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: PlayerItemConfiguration = .default
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
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: PlayerItemConfiguration = .default
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
    ///   - configuration: The configuration to apply to the player item.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        trackerAdapters: [TrackerAdapter<Void>] = [],
        configuration: PlayerItemConfiguration = .default
    ) -> Self {
        .init(
            asset: .encrypted(url: url, delegate: delegate, configuration: configuration),
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
        "\(content)"
    }
}
