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
        expect(Time.timeRange(for: item)).to(equal(
            CMTimeRangeMake(start: .zero, duration: CMTime(value: 120, timescale: 1)),
            by: close(within: 0.5)
        ))
    }

    func testProgress() {
        expect(Time.progress(
            for: CMTimeMake(value: 1, timescale: 2),
            in: CMTimeRangeMake(start: .zero, duration: CMTimeMake(value: 1, timescale: 1))
        )).to(equal(0.5))
    }
}
