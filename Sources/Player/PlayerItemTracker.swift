//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Common contract for player item tracker implementation. Initialization and deinitialization methods can be used
/// to track items even when they are not currently being played.
public protocol PlayerItemTracker: AnyObject {
    /// The type of metadata required by the tracker.
    associatedtype Metadata

    /// Initialize the tracker.
    init()

    /// Called when the tracker is enabled for a player.
    /// - Parameter player: The player for which the tracker must be enabled.
    func enable(for player: Player)

    /// Called when the tracker metadata is updated.
    func update(metadata: Metadata)

    /// Called when the tracker is disabled.
    func disable()
}

public extension PlayerItemTracker {
    /// Creates a tracker adapter for the tracker that maps its metadata type to a different metadata.
    /// - Parameter mapper: A closure that maps the tracker's metadata to another metadata.
    /// - Returns: A `TrackerAdapter` instance that adapts the tracker to the new metadata.
    static func adapter<M: AssetMetadata>(mapper: @escaping (M) -> Metadata) -> TrackerAdapter<M> {
        TrackerAdapter(trackerType: Self.self, mapper: mapper)
    }
}

public extension PlayerItemTracker where Metadata == Void {
    /// Creates a tracker adapter for the tracker with Void metadata.
    /// - Returns: A `TrackerAdapter` instance that adapts the tracker with Void metadata.
    static func adapter<M: AssetMetadata>() -> TrackerAdapter<M> {
        TrackerAdapter(trackerType: Self.self) { _ in }
    }
}
