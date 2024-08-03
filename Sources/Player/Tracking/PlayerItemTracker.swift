//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for custom player item tracking implementation.
///
/// For more information about implementing custom trackers please read <doc:tracking>.
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
    /// - Parameter configuration: The tracker configuration.
    init(configuration: Configuration)

    /// A method called when the tracker is enabled for a player.
    ///
    /// - Parameter player: The player for which the tracker must be enabled.
    func enable(for player: AVPlayer)

    /// A method called when metadata is updated.
    ///
    /// - Parameter metadata: The updated metadata.
    ///
    /// This method is always called, no matter whether the tracker is currently active or not.
    func updateMetadata(to metadata: Metadata)

    /// A method called when player properties have changed.
    ///
    /// - Parameter properties: The updated properties.
    ///
    /// This method can be called quite often, but only when the tracker is active. Implementations should avoid
    /// performing significant work unnecessarily.
    func updateProperties(to properties: PlayerProperties)

    /// A method called when metric events are updated.
    ///
    /// - Parameter event: The received event.
    ///
    /// This method is only called when the tracker is active.
    func updateMetricEvents(to events: [MetricEvent])

    /// A method called when the tracker is disabled.
    ///
    /// - Parameter properties: The updated properties.
    func disable(with properties: PlayerProperties)
}

public extension PlayerItemTracker {
    /// Creates an adapter for the receiver with the provided mapping to its metadata format.
    ///
    /// - Parameters:
    ///   - configuration: The tracker configuration.
    ///   - mapper: A closure that maps an item metadata to tracker metadata.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: configuration, mapper: mapper)
    }
}

public extension PlayerItemTracker where Configuration == Void {
    /// Creates an adapter for the receiver.
    /// 
    /// - Parameter mapper: A closure that maps an item metadata to tracker metadata.
    /// - Returns: The tracker adapter.
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: (), mapper: mapper)
    }
}

public extension PlayerItemTracker where Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Parameter configuration: The tracker configuration.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: configuration) { _ in }
    }
}

public extension PlayerItemTracker where Configuration == Void, Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Returns: The tracker adapter.
    static func adapter<M>() -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: ()) { _ in }
    }
}
