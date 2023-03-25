//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Common contract for player item tracker implementation. Initialization and deinitialization methods can be used
/// to track items even when they are not currently being played.
public protocol PlayerItemTracker: AnyObject {
    /// A type describing the configuration required by the tracker. May be `Void` if none.
    associatedtype Configuration

    /// A type describing metadata required by the tracker. May be `Void` if none.
    associatedtype Metadata

    /// Initialize the tracker.
    init(configuration: Configuration)

    /// Called when the tracker is enabled for a player.
    /// - Parameter player: The player for which the tracker must be enabled.
    func enable(for player: Player)

    /// Called when the tracker metadata is updated.
    func update(metadata: Metadata)

    /// Called when the tracker is disabled.
    func disable()
}

public extension PlayerItemTracker {
    /// Create an adapter for the receiver with the provided mapping to its metadata format.
    /// - Parameters:
    ///   - configuration: The tracker configuration.
    ///   - mapper: A closure that maps the tracker's metadata to another metadata.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: configuration, mapper: mapper)
    }
}

public extension PlayerItemTracker where Metadata == Void {
    /// Create an adapter for the receiver.
    /// - Parameter configuration: The tracker configuration.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration) -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: configuration) { _ in }
    }
}

public extension PlayerItemTracker where Configuration == Void {
    /// Create an adapter for the receiver.
    /// - Parameter configuration: The tracker configuration.
    /// - Returns: The tracker adapter.
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: (), mapper: mapper)
    }
}

public extension PlayerItemTracker where Metadata == Void, Configuration == Void {
    /// Create an adapter for the receiver.
    /// - Returns: The tracker adapter.
    static func adapter<M>() -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: ()) { _ in }
    }
}
