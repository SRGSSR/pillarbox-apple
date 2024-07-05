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
            expectEqualPublished(
                values: [nil],
                from: player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4)),
                during: .seconds(1)
            )
    }

    func testPlayback() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [nil, Stream.onDemand.url.absoluteString],
            from: player.periodicMetricsPublisher(forInterval: .init(value: 1, timescale: 4))
                .map(\.?.uri)
        ) {
            player.play()
        }
    }

    func testPlaylist() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.mediumOnDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [nil, Stream.shortOnDemand.url.absoluteString, Stream.mediumOnDemand.url.absoluteString],
            from: player.periodicMetricsPublisher(forInterval: .init(value: 2, timescale: 1))
                .map(\.?.uri)
        ) {
            player.play()
        }
    }
}
