//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol PlayerItemTracking {
    var behavior: TrackingBehavior { get }
    var registration: TrackingRegistration? { get }

    func enable(for player: AVPlayer)
    func updateProperties(to properties: TrackerProperties)
    func updateMetricEvents(to events: [MetricEvent])
    func disable(with properties: TrackerProperties)
}
