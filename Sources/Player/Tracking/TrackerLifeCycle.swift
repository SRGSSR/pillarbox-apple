//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol TrackerLifeCycle {
    func enable(for player: Player)
    func updateProperties(with properties: PlayerProperties)
    func receiveMetricEvent(_ event: MetricEvent)

    @available(iOS 18.0, tvOS 18.0, *)
    func receiveNativeMetricEvent(_ event: AVMetricEvent)

    func disable()
}
