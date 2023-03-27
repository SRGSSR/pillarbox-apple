//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An adapter which instantiates and manages a tracker of a specified type, transforming metadata delivered by the
/// tracked player item into the metadata format required by the tracker.
public struct TrackerAdapter<M: AssetMetadata> {
    private let tracker: any PlayerItemTracker
    private let update: (M) -> Void

    /// Create an adapter for a type of tracker with the provided mapping to its metadata format.
    /// - Parameters:
    ///   - trackerType: The type of the tracker to instantiate and manage.
    ///   - configuration: The tracker configuration.
    ///   - mapper: The metadata mapper.
    public init<T>(trackerType: T.Type, configuration: T.Configuration, mapper: @escaping (M) -> T.Metadata) where T: PlayerItemTracker {
        let tracker = trackerType.init(configuration: configuration)
        update = { metadata in
            tracker.update(metadata: mapper(metadata))
        }
        self.tracker = tracker
    }

    func enable(for player: Player) {
        tracker.enable(for: player)
    }

    func update(metadata: M) {
        update(metadata)
    }

    func disable() {
        tracker.disable()
    }
}
