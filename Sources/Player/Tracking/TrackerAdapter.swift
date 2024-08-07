//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// An adapter which instantiates and manages a tracker of a specified type.
///
/// An adapter transforms metadata delivered by a player item into the metadata format required by the tracker.
public struct TrackerAdapter<M> {
    private let tracker: any PlayerItemTracker
    private let update: (M) -> Void

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
                tracker.updateMetadata(to: mapper(metadata))
            }
        }
        self.tracker = tracker
    }

    func updateMetadata(to metadata: M) {
        update(metadata)
    }
}

extension TrackerAdapter: TrackerLifeCycle {
    var description: String? {
        tracker.description
    }

    func enable(for player: AVPlayer) {
        tracker.enable(for: player)
    }

    func updateProperties(to properties: PlayerProperties) {
        tracker.updateProperties(to: properties)
    }

    func updateMetricEvents(to events: [MetricEvent]) {
        tracker.updateMetricEvents(to: events)
    }

    func disable(with properties: PlayerProperties) {
        tracker.disable(with: properties)
    }
}
