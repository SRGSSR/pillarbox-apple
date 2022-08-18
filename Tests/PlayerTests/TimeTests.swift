//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class TimeTests: XCTestCase {
    func testOnDemandTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }
        expect(Player.timeRange(for: item)).to(equal(
            CMTimeRangeMake(start: .zero, duration: CMTime(value: 3, timescale: 1)),
            by: close(within: 0.1)
        ))
    }

    func testProgress() {
    }
}
