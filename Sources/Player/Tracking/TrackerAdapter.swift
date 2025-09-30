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
    let behavior: TrackingBehavior

    private let tracker: any PlayerItemTracker
    private let update: (M) -> Void
    private let queue = DispatchQueue(label: "ch.srgssr.tracker-adapter")

    init<T>(
        trackerType: T.Type,
        configuration: T.Configuration,
        behavior: TrackingBehavior,
        mapper: ((M) -> T.Metadata)?
    ) where T: PlayerItemTracker {
        let tracker = trackerType.init(configuration: configuration, queue: queue)
        update = { metadata in
            if let mapper {
                tracker.updateMetadata(to: mapper(metadata))
            }
        }
        self.tracker = tracker
        self.behavior = behavior
    }

    func updateMetadata(to metadata: M) {
        update(metadata)
    }
}

extension TrackerAdapter: PlayerItemTracking {
    var registration: TrackingRegistration? {
        guard let sessionIdentifier = tracker.sessionIdentifier else { return nil }
        return .init(type: type(of: tracker), sessionIdentifier: sessionIdentifier)
    }

    func enable(for player: AVPlayer) {
        queue.async {
            tracker.enable(for: player)
        }
    }

    func updateProperties(to properties: TrackerProperties) {
        queue.async {
            tracker.updateProperties(to: properties)
        }
    }

    func updateMetricEvents(to events: [MetricEvent]) {
        queue.async {
            tracker.updateMetricEvents(to: events)
        }
    }

    func disable(with properties: TrackerProperties) {
        queue.async {
            tracker.disable(with: properties)
        }
    }
}
