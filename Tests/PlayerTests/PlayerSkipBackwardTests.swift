//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble
import XCTest

final class PlayerSkipForwardTests: XCTestCase {
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipForward()).to(beFalse())
    }

    func testCanSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipForward()).to(beTrue())
    }

    func testCanSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipForward()).to(beFalse())
    }

    func testCanSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipForward()).to(beTrue())
    }

    func testSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))

        waitUntil { done in
            player.skipForward { _ in
                expect(player.time).to(equal(CMTime(value: 10, timescale: 1), by: beClose(within: player.chunkDuration.seconds)))
                done()
            }
        }
    }

    func testMultipleSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))

        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beFalse())
            }

            player.skipForward { finished in
                expect(player.time).to(equal(CMTime(value: 20, timescale: 1), by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        player.skipForward { _ in
            fail()
        }
    }

    func testSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time

        player.skipForward { finished in
            expect(player.time).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
            expect(finished).to(beTrue())
        }
    }

    func testSkipAsync() async {
        await expect(true).to(beTrue())
    }
}
