//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class MetricsCollectorEventsTests: TestCase {
    func testUnbound() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        expect(metricsCollector.metricEvents).toAlways(beEmpty(), until: .milliseconds(500))
    }

    func testEmptyPlayer() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        metricsCollector.player = Player()
        expect(metricsCollector.metricEvents).toAlways(beEmpty(), until: .milliseconds(500))
    }

    func testPausedPlayer() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let player = Player(item: .simple(url: Stream.onDemand.url))
        metricsCollector.player = player
        expect(metricsCollector.metricEvents).toEventuallyNot(beEmpty())
    }

    func testPlayerSetToNil() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        metricsCollector.player = player
        player.play()
        expect(metricsCollector.metricEvents).toEventuallyNot(beEmpty())

        metricsCollector.player = nil
        expect(metricsCollector.metricEvents).to(beEmpty())
    }
}
