//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Streams
import XCTest

final class AVPlayerRatePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [0],
            from: player.ratePublisher()
        )
    }

    func testOnDemand() {
        let player = AVPlayer(url: Stream.onDemand.url)
        expectAtLeastEqualPublished(
            values: [0, 1],
            from: player.ratePublisher()
        ) {
            player.play()
        }
    }
}
