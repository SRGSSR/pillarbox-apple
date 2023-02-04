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

final class PlayerSkipBackwardTests: XCTestCase {
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipBackward()).to(beFalse())
    }

    func testCanSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipBackward()).to(beTrue())
    }

    func testCanSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipBackward()).to(beFalse())
    }

    func testCanSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipBackward()).to(beTrue())
    }

    func testSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))

        waitUntil { done in
            player.skipBackward { _ in
                expect(player.time).to(equal(.zero))
                done()
            }
        }
    }

    func testMultipleSkipsForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))

        waitUntil { done in
            player.skipBackward { finished in
                expect(finished).to(beFalse())
            }

            player.skipBackward { finished in
                expect(player.time).to(equal(.zero))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        player.skipBackward { _ in
            fail()
        }
    }

    func testSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time

        player.skipBackward { finished in
            expect(player.time).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
            expect(finished).to(beTrue())
        }
    }
}
