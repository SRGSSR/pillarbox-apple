//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for custom player item tracking implementation.
///
/// For more information about implementing custom trackers please read <doc:tracking-article>.
public protocol PlayerItemTracker: AnyObject {
    /// A type describing the configuration required by the tracker.
    ///
    /// Use `Void` if no configuration is required.
    associatedtype Configuration

    /// A type describing metadata required by the tracker.
    ///
    /// Use `Void` if no metadata is required.
    associatedtype Metadata

    /// An optional session identifier.
    ///
    /// Session identifiers can be useful for tracker data inspection purposes. An example is a tracker collecting and
    /// sending monitoring data to a server. By assigning a session identifier appearing in the data that is sent, you can
    /// use ``Player/currentSessionIdentifiers(trackedBy:)`` to extract at any time the list of relevant session identifiers,
    /// letting you locate the matching data server-side.
    ///
    /// This feature can be essential for customer support. In case of need you can namely have a customer send your
    /// team their session identifier, obtained with ``Player/currentSessionIdentifiers(trackedBy:)``. This way your
    /// customer support team can inspect the data associated with the user session and help the user understand the
    /// issues they might experience.
    var sessionIdentifier: String? { get }

    /// Creates the tracker.
    ///
    /// - Parameter configuration: The tracker configuration.
    init(configuration: Configuration)

    /// A method called when the tracker is enabled for a player.
    ///
    /// - Parameter player: The player for which the tracker must be enabled.
    ///
    /// > Important: This method is called on a background thread.
    func enable(for player: AVPlayer)

    /// A method called when metadata is updated.
    ///
    /// - Parameter metadata: The updated metadata.
    ///
    /// This method is always called, whether the tracker is currently active or not.
    ///
    /// > Important: This method is called on a background thread.
    func updateMetadata(to metadata: Metadata)

    /// A method called when player properties have changed.
    ///
    /// - Parameter properties: The updated properties.
    ///
    /// This method can be called quite often, but only when the tracker is active. Implementations should avoid
    /// performing significant work unnecessarily.
    ///
    /// > Important: This method is called on a background thread.
    func updateProperties(to properties: TrackerProperties)

    /// A method called when metric events are updated.
    ///
    /// - Parameter events: All events that have currently been recorded for the item.
    ///
    /// This method is only called when the tracker is active.
    ///
    /// > Important: This method is called on a background thread.
    func updateMetricEvents(to events: [MetricEvent])

    /// A method called when the tracker is disabled.
    ///
    /// - Parameter properties: The updated properties.
    ///
    /// > Important: This method is called on a background thread.
    func disable(with properties: TrackerProperties)
}

public extension PlayerItemTracker {
    /// The default session identifier.
    var sessionIdentifier: String? {
        nil
    }

    /// Creates an adapter for the receiver with the provided mapping to its metadata format.
    ///
    /// - Parameters:
    ///   - configuration: The tracker configuration.
    ///   - behavior: The tracking behavior.
    ///   - mapper: A closure that maps an item metadata to tracker metadata.
    /// - Returns: The tracker adapter.
    static func adapter<M>(
        configuration: Configuration,
        behavior: TrackingBehavior = .optional,
        mapper: @escaping (M) -> Metadata
    ) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: configuration, behavior: behavior, mapper: mapper)
    }
}

public extension PlayerItemTracker where Configuration == Void {
    /// Creates an adapter for the receiver.
    /// 
    /// - Parameters:
    ///   - behavior: The tracking behavior.
    ///   - mapper: A closure that maps an item metadata to tracker metadata.
    /// - Returns: The tracker adapter.
    static func adapter<M>(behavior: TrackingBehavior = .optional, mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: (), behavior: behavior, mapper: mapper)
    }
}

public extension PlayerItemTracker where Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Parameters:
    ///   - configuration: The tracker configuration.
    ///   - behavior: The tracking behavior.
    /// - Returns: The tracker adapter.
    static func adapter<M>(configuration: Configuration, behavior: TrackingBehavior = .optional) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: configuration, behavior: behavior) { _ in }
    }
}

public extension PlayerItemTracker where Configuration == Void, Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Parameter behavior: The tracking behavior.
    ///
    /// - Returns: The tracker adapter.
    static func adapter<M>(behavior: TrackingBehavior = .optional) -> TrackerAdapter<M> {
        .init(trackerType: Self.self, configuration: (), behavior: behavior) { _ in }
    }
}
