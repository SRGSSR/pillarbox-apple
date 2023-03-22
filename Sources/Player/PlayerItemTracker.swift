//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A type that represents a tracker.
public protocol PlayerItemTracker {
    associatedtype Metadata

    /// Initializes a tracker.
    init()

    /// Called when a tracker is enabled for a player.
    /// - Parameter player: The player to which the tracker must be enabled.
    func enable(for player: Player)

    /// Called when a tracker metadata is updated.
    func update(with metadata: Metadata)

    /// Called when a tracker is disabled for a player.
    func disable()
}

public protocol TrackerAdaptable {
    associatedtype M
    func update(metadata: M)
    func enable(for player: Player)
    func disable()
}

public struct TrackerAdapter<T: PlayerItemTracker, M>: TrackerAdaptable {
    let tracker: T
    let mapper: (M) -> T.Metadata

    public init(trackerType: T.Type, mapper: @escaping (M) -> T.Metadata) {
        self.tracker = trackerType.init()
        self.mapper = mapper
    }

    public func enable(for player: Player) {
        tracker.enable(for: player)
    }

    public func update(metadata: M) {
        tracker.update(with: mapper(metadata))
    }

    public func disable() {
        tracker.disable()
    }
}
