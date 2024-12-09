//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import PillarboxCircumspect
import PillarboxStreams

final class PeriodicMetricsPublisherTests: TestCase {
    func testEmpty() {
        let player = Player()
        expectAtLeastEqualPublished(
            values: [0],
            from: player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4)).map(\.count)
        )
    }

    func testPlayback() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [0, 1, 2],
            from: player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4)).map(\.count)
        ) {
            player.play()
        }
    }

    func testPlaylist() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.mediumOnDemand.url)
        let player = Player(items: [item1, item2])
        let publisher = player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 1)).map(\.count)
        expectAtLeastEqualPublished(values: [0, 1, 0, 1], from: publisher) {
            player.play()
        }
    }

    func testNoMetricsForLiveMp3() {
        let player = Player(item: .simple(url: Stream.liveMp3.url))
        let publisher = player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4)).map(\.count)
        expectAtLeastEqualPublished(values: [0], from: publisher) {
            player.play()
        }
    }

    func testLimit() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [0, 1, 2, 2, 2, 2],
            from: player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4), limit: 2).map(\.count)
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = PlayerItem.failing(loadedAfter: 0.1)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [0],
            from: player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4)).map(\.count)
        )
    }
}
