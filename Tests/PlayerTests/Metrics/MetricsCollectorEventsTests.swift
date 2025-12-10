//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class MetricsCollectorEventsTests: TestCase {
    @MainActor
    func testUnbound() async {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        await expect(metricsCollector.metricEvents).toAlways(beEmpty(), until: .milliseconds(500))
    }

    @MainActor
    func testEmptyPlayer() async {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        metricsCollector.player = Player()
        await expect(metricsCollector.metricEvents).toAlways(beEmpty(), until: .milliseconds(500))
    }

    @MainActor
    func testPausedPlayer() async {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let player = Player(item: .simple(url: Stream.onDemand.url))
        metricsCollector.player = player
        await expect(metricsCollector.metricEvents).toEventuallyNot(beEmpty())
    }

    @MainActor
    func testPlayerSetToNil() async {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        metricsCollector.player = player
        player.play()
        await expect(metricsCollector.metricEvents).toEventuallyNot(beEmpty())

        metricsCollector.player = nil
        expect(metricsCollector.metricEvents).to(beEmpty())
    }
}
