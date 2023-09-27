//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// A protocol for player item tracking implementation.
///
/// If your application needs to track items being played, for example for analytics or diagnostics purposes, implement
/// this protocol to hook into the playback lifecycle. This allows you to setup your tracker at and to relinquish
/// associated resources when appropriate.
///
/// The protocol provides two associated types through which your tracker can define any configuration or metadata it
/// requires. Trackers are never instantiated directly but rather using adapter methods which let you map metadata
/// provided by a player item to the required tracker metadata.
///
/// This protocol can only be applied to reference types. This makes it possible to use initialization and
/// deinitialization methods to perform tracking also when the item is currently not being played.
public protocol PlayerItemTracker: AnyObject {
    /// A type describing the configuration required by the tracker.
    ///
    /// Use `Void` if no configuration is required.
    associatedtype Configuration

    /// A type describing metadata required by the tracker.
    ///
    /// Use `Void` if no metadata is required.
    associatedtype Metadata

    /// Creates the tracker.
    ///
    /// - Parameters:
    ///   - configuration: The tracker configuration.
    ///   - metadataPublisher: The publisher that provides metadata updates.
    init(configuration: Configuration, metadataPublisher: AnyPublisher<Metadata, Never>)

    /// The lifecycle method called when the tracker is enabled for a player.
    ///
    /// - Parameter player: The player for which the tracker must be enabled.
    func enable(for player: Player)

    /// The lifecycle method called when the tracker is disabled.
    func disable()
}

public extension PlayerItemTracker {
    /// Creates an adapter for the receiver with the provided mapping to its metadata format.
    ///
    /// - Parameters:
    ///   - configuration: The tracker configuration.
    ///   - mapper: A closure that maps the tracker's metadata to another metadata.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: configuration, mapper: mapper)
    }

    /// Creates an adapter for the receiver.
    ///
    /// - Parameter configuration: The tracker configuration.
    /// - Returns: The tracker adapter.
    static func adapter(configuration: Configuration) -> TrackerAdapter<Never> {
        TrackerAdapter(trackerType: Self.self, configuration: configuration, mapper: nil)
    }
}

public extension PlayerItemTracker where Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Parameter configuration: The tracker configuration.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration) -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: configuration) { _ in }
    }
}

public extension PlayerItemTracker where Configuration == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Parameter configuration: The tracker configuration.
    /// - Returns: The tracker adapter.
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: (), mapper: mapper)
    }

    /// Creates an adapter for the receiver.
    ///
    /// - Returns: The tracker adapter.
    static func adapter() -> TrackerAdapter<Never> {
        TrackerAdapter(trackerType: Self.self, configuration: (), mapper: nil)
    }
}

public extension PlayerItemTracker where Metadata == Void, Configuration == Void {
    /// Creates an adapter for the receiver.
    /// 
    /// - Returns: The tracker adapter.
    static func adapter<M>() -> TrackerAdapter<M> where M: AssetMetadata {
        TrackerAdapter(trackerType: Self.self, configuration: ()) { _ in }
    }
}
