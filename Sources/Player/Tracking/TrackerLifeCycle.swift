//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol TrackerLifeCycle {
    func enable(for player: Player)
    func updateProperties(with properties: PlayerProperties)
    func updateMetrics(with events: [MetricEvent])
    func disable()
}
