//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An adapter which instantiates and manages a tracker of a specified type.
///
/// An adapter transforms metadata delivered by a player item into the metadata format required by the tracker.
public class TrackerAdapter<M> {
    private let tracker: any PlayerItemTracker
    private let update: (M) -> Void
    private var id = UUID()

    /// Creates an adapter for a type of tracker with the provided mapper.
    /// 
    /// - Parameters:
    ///   - trackerType: The type of the tracker to instantiate and manage.
    ///   - configuration: The tracker configuration.
    ///   - mapper: The metadata mapper.
    public init<T>(trackerType: T.Type, configuration: T.Configuration, mapper: ((M) -> T.Metadata)?) where T: PlayerItemTracker {
        let tracker = trackerType.init(configuration: configuration)
        update = { metadata in
            if let mapper {
                tracker.updateMetadata(with: mapper(metadata))
            }
        }
        self.tracker = tracker
    }

    func withId(_ id: UUID) -> Self {
        self.id = id
        return self
    }

    func updateMetadata(with metadata: M) {
        update(metadata)
    }
}

extension TrackerAdapter: TrackerLifeCycle {
    func enable(for player: Player) {
        tracker.enable(for: player)
    }

    func updateProperties(with properties: PlayerProperties) {
        guard properties.id == id else { return }
        tracker.updateProperties(with: properties)
    }

    func updateMetrics(with events: [MetricLogEvent]) {
        tracker.updateMetrics(with: events)
    }

    func disable() {
        tracker.disable()
    }
}
