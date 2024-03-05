//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

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
    func enable(for player: Player)

    /// A method called when tracker metadata is updated.
    ///
    /// - Parameter metadata: The updated metadata.
    func updateMetadata(with metadata: Metadata)

    /// A method called when player properties have changed.
    ///
    /// - Parameter properties: The updated properties.
    ///
    /// This method can be called quite often. Implementations should avoid performing significant work unnecessarily.
    func updateProperties(with properties: PlayerProperties)

    /// A method called when the tracker is disabled.
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
