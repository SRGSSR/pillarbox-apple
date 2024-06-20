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

final class MetricsCollectorTests: TestCase {
    func testUnbound() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [[]],
            from: metricsCollector.$metrics
                .map { $0.compactMap(\.uri) }
                .removeDuplicates()
        )
    }

    func testEmptyPlayer() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [[]],
            from: metricsCollector.$metrics
                .map { $0.compactMap(\.uri) }
                .removeDuplicates()
        ) {
            metricsCollector.player = Player()
        }
    }

    func testPausedPlayer() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [[]],
            from: metricsCollector.$metrics
                .map { $0.compactMap(\.uri) }
                .removeDuplicates()
        ) {
            metricsCollector.player = player
        }
    }

    func testPlayback() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [[], [Stream.onDemand.url.absoluteString]],
            from: metricsCollector.$metrics
                .map { $0.compactMap(\.uri) }
                .removeDuplicates()
        ) {
            metricsCollector.player = player
            player.play()
        }
    }

    func testPlayerSetToNil() {
        let metricsCollector = MetricsCollector(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        metricsCollector.player = player
        player.play()
        expect(metricsCollector.metrics).toEventuallyNot(beEmpty())

        metricsCollector.player = nil
        expect(metricsCollector.metrics).notTo(beEmpty())
    }
}
