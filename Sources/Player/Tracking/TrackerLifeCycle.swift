//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol TrackerLifeCycle {
    func enable(for player: AVPlayer)
    func updateProperties(with properties: PlayerProperties, time: CMTime)
    func receiveMetricEvent(_ event: MetricEvent)
    func disable(with properties: PlayerProperties, time: CMTime)
}
