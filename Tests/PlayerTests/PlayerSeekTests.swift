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

final class PlayerSeekTests: XCTestCase {
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

    // ---

    func testSeekWithEmptyPlayer() {
        let player = Player()
        waitUntil { done in
            player.seek(to: .zero) { finished in
                expect(finished).to(beFalse())
                done()
            }
        }
    }

    func testSeekInTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(to: CMTimeMultiplyByFloat64(Stream.onDemand.duration, multiplier: 0.5)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekInEmptyTimeRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.seek(to: .zero) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekToTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(to: player.timeRange.start) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekToTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(to: player.timeRange.end) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekBeforeTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(to: CMTime(value: -10, timescale: 1)) { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(.zero))
                done()
            }
        }
    }

    func testSeekAfterTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(to: player.timeRange.end + CMTime(value: 10, timescale: 1)) { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(player.timeRange.end, by: beClose(within: player.chunkDuration.seconds)))
                done()
            }
        }
    }

    func testTimesDuringSeekBeforeTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.play()
        player.seek(to: CMTime(value: -10, timescale: 1))
        expect(player.time).toAlways(beGreaterThanOrEqualTo(player.timeRange.start))
    }

    func testTimesDuringSeekAfterTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.play()
        player.seek(to: player.timeRange.end + CMTime(value: 10, timescale: 1))
        expect(player.time).toAlways(beLessThanOrEqualTo(player.timeRange.end))
    }
}
