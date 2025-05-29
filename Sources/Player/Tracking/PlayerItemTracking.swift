//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol PlayerItemTracking {
    var behavior: TrackingBehavior { get }
    var registration: TrackingRegistration? { get async }

    func enable(for player: AVPlayer) async
    func updateProperties(to properties: TrackerProperties) async
    func updateMetricEvents(to events: [MetricEvent]) async
    func disable(with properties: TrackerProperties) async
}
