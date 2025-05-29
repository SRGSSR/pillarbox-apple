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

    init<T>(
        trackerType: T.Type,
        configuration: T.Configuration,
        behavior: TrackingBehavior,
        mapper: ((M) -> T.Metadata)?
    ) where T: PlayerItemTracker {
        let tracker = trackerType.init(configuration: configuration)
        update = { metadata in
            if let mapper {
                Task {
                    await tracker.updateMetadata(to: mapper(metadata))
                }
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
        get async {
            guard let sessionIdentifier = await tracker.sessionIdentifier else { return nil }
            return .init(type: type(of: tracker), sessionIdentifier: sessionIdentifier)
        }
    }

    func enable(for player: AVPlayer) async {
        await tracker.enable(for: player)
    }

    func updateProperties(to properties: TrackerProperties) async {
        await tracker.updateProperties(to: properties)
    }

    func updateMetricEvents(to events: [MetricEvent]) async {
        await tracker.updateMetricEvents(to: events)
    }

    func disable(with properties: TrackerProperties) async {
        await tracker.disable(with: properties)
    }
}
