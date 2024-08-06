//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol TrackerLifeCycle {
    var description: String? { get }

    func enable(for player: AVPlayer)
    func updateProperties(to properties: PlayerProperties)
    func updateMetricEvents(to events: [MetricEvent])
    func disable(with properties: PlayerProperties)
}
