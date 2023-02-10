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
    func testSeekWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.seek(to: .zero) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekWhenEmptyAsync() async {
        let player = Player()
        await expect { await player.seek(to: .zero) }.to(beTrue())
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
