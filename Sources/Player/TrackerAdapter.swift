//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An adapter which instantiates and manages a tracker of a specified type, transforming metadata delivered by
/// a player item into the format required by the tracker.
public struct TrackerAdapter<T: PlayerItemTracker, M> {
    private let tracker: T
    private let mapper: (M) -> T.Metadata

    /// Create an adapter for a type of tracker with the provided mapping to its metadata format.
    /// - Parameters:
    ///   - trackerType: The type of the tracker to manage.
    ///   - mapper: The metadata mapper.
    public init(trackerType: T.Type, mapper: @escaping (M) -> T.Metadata) {
        self.tracker = trackerType.init()
        self.mapper = mapper
    }

    func enable(for player: Player) {
        tracker.enable(for: player)
    }

    func update(metadata: M) {
        tracker.update(with: mapper(metadata))
    }

    func disable() {
        tracker.disable()
    }
}
