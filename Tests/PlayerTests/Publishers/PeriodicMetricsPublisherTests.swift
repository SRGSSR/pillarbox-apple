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
}
