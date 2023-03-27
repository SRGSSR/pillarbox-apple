//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class SeekChecksTests: TestCase {
    func testCannotSeekWithEmptyPlayer() {
        let player = Player()
        expect(player.canSeek(to: .zero)).to(beFalse())
    }

    func testCanSeekInTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: CMTimeMultiplyByFloat64(Stream.onDemand.duration, multiplier: 0.5))).to(beTrue())
    }

    func testCannotSeekInEmptyTimeRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSeek(to: .zero)).to(beFalse())
    }

    func testCanSeekToTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.timeRange.start)).to(beTrue())
    }

    func testCanSeekToTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.timeRange.end)).to(beTrue())
    }

    func testCannotSeekBeforeTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: CMTime(value: -10, timescale: 1))).to(beFalse())
    }

    func testCannotSeekAfterTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.timeRange.end + CMTime(value: 1, timescale: 1))).to(beFalse())
    }
}
