//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core

/// An item to be inserted into a player.
public final class PlayerItem: Equatable {
    @Published private(set) var asset: any Assetable

    private let id = UUID()

    /// Creates an item from an `Asset` publisher data source.
    ///
    /// - Parameters:
    ///   - asset: The asset to be played.
    ///   - position: The starting position.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    /// - Returns: The item.
    public init<P, M>(
        publisher: P,
        position: @escaping () -> Position? = { nil },
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where P: Publisher, M: AssetMetadata, P.Output == Asset<M> {
        asset = Asset<M>.loading.withId(id).withTrackerAdapters(trackerAdapters).withPosition(position)
        publisher
            .catch { error in
                Just(.failed(error: error))
            }
            .map { [id] asset in
                asset.withId(id).withTrackerAdapters(trackerAdapters).withPosition(position)
            }
            // Mitigate instabilities arising when publisher involves `URLSession` publishers, see issue #206.
            .receiveOnMainThread()
            .assign(to: &$asset)
    }

    /// Creates an item from an `Asset` data source.
    ///
    /// - Parameters:
    ///   - asset: The asset to be played.
    ///   - position: The starting position.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    /// - Returns: The item.
    public convenience init<M>(
        asset: Asset<M>,
        position: @escaping () -> Position? = { nil },
        trackerAdapters: [TrackerAdapter<M>] = []
    ) where M: AssetMetadata {
        self.init(publisher: Just(asset), position: position, trackerAdapters: trackerAdapters)
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        asset.matches(playerItem)
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - position: The starting position.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple<M>(
        url: URL,
        position: @escaping () -> Position? = { nil },
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(asset: .simple(url: url, metadata: metadata, configuration: configuration), position: position, trackerAdapters: trackerAdapters)
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - position: The starting position.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom<M>(
        url: URL,
        position: @escaping () -> Position? = { nil },
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .custom(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            position: position,
            trackerAdapters: trackerAdapters
        )
    }

    /// Returns an encrypted item loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - position: The starting position.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the item.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted<M>(
        url: URL,
        position: @escaping () -> Position? = { nil },
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        trackerAdapters: [TrackerAdapter<M>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self where M: AssetMetadata {
        .init(
            asset: .encrypted(url: url, delegate: delegate, metadata: metadata, configuration: configuration),
            position: position,
            trackerAdapters: trackerAdapters
        )
    }
}

public extension PlayerItem {
    /// Returns a simple playable item.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - position: The starting position.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func simple(
        url: URL,
        position: @escaping () -> Position? = { nil },
        trackerAdapters: [TrackerAdapter<Never>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .simple(url: url, configuration: configuration), position: position, trackerAdapters: trackerAdapters)
    }

    /// Returns an item loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - position: The starting position.
    ///   - delegate: The custom resource loader to use.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        position: @escaping () -> Position? = { nil },
        delegate: AVAssetResourceLoaderDelegate,
        trackerAdapters: [TrackerAdapter<Never>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .custom(url: url, delegate: delegate, configuration: configuration), position: position, trackerAdapters: trackerAdapters)
    }

    /// Returns an encrypted item loaded with a content key session.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - position: The starting position. 
    ///   - delegate: The content key session delegate to use.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The item.
    static func encrypted(
        url: URL,
        position: @escaping () -> Position? = { nil },
        delegate: AVContentKeySessionDelegate,
        trackerAdapters: [TrackerAdapter<Never>] = [],
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(asset: .encrypted(url: url, delegate: delegate, configuration: configuration), position: position, trackerAdapters: trackerAdapters)
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(asset)"
    }
}
