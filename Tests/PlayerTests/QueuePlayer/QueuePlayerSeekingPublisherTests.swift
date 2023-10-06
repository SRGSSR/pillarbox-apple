//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Streams

final class QueuePlayerSeekingPublisherTests: TestCase {
    func testSeek() {
        let player = QueuePlayer(
            playerItem: .init(url: Stream.onDemand.url)
        )
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.isSeekingPublisher()
        ) {
            player.seek(to: .init(value: 1, timescale: 1))
        }
    }
}
