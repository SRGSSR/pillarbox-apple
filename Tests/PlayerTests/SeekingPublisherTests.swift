//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class SeekingPublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [false],
            from: player.seekingPublisher(),
            during: 2
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expectEqualPublished(
            values: [false, true, false],
            from: player.seekingPublisher(),
            during: 2
        ) {
            player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }
    }
}
