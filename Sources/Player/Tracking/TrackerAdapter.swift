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
    let isMandatory: Bool
    private let update: (M) -> Void

    init<T>(
        trackerType: T.Type,
        mandatory: Bool = false,
        configuration: T.Configuration,
        mapper: ((M) -> T.Metadata)?
    ) where T: PlayerItemTracker {
        let tracker = trackerType.init(configuration: configuration)
        update = { metadata in
            if let mapper {
                tracker.updateMetadata(to: mapper(metadata))
            }
        }
        self.tracker = tracker
        self.isMandatory = mandatory
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
