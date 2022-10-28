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

// TODO: Write tests for async API once Nimble has been updated with async / await support (version 11).

@MainActor
final class PlayerSkipToLiveTests: XCTestCase {
    func testCannotSkipToLiveWhenEmpty() {
        let player = Player()
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCannotSkipToLiveForOnDemand() {
        let item = PlayerItem(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCannotSkipToLiveForLive() {
        let item = PlayerItem(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCannotSkipToLiveForDvrInLiveConditions() {
        let item = PlayerItem(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.time).toNotEventually(equal(.zero))
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCanSkipToLiveForDvrInPastConditions() {
        let item = PlayerItem(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.time).toNotEventually(equal(.zero))

        waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        expect(player.canSkipToLive()).toAlways(beTrue())
    }

    func testSkipToLiveWhenEmpty() {
        let player = Player()
        let skipped = player.skipToLive { finished in
            fail("Must not be called")
        }
        expect(skipped).to(beFalse())
    }

    func testSkipToLiveForOnDemand() {
        let item = PlayerItem(url: Stream.onDemand.url)
        let player = Player(item: item)
        let skipped = player.skipToLive { finished in
            fail("Must not be called")
        }
        expect(skipped).to(beFalse())
    }

    func testSkipToLiveForLive() {
        let item = PlayerItem(url: Stream.live.url)
        let player = Player(item: item)
        let skipped = player.skipToLive { finished in
            fail("Must not be called")
        }
        expect(skipped).to(beFalse())
    }

    func testSkipToLiveForDvrInLiveConditions() {
        let item = PlayerItem(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.time).toNotEventually(equal(.zero))
        let skipped = player.skipToLive { finished in
            fail("Must not be called")
        }
        expect(skipped).to(beFalse())
    }

    func testSkipToLiveForDvrInPastConditions() {
        let item = PlayerItem(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.time).toNotEventually(equal(.zero))

        waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        waitUntil { done in
            let skipped = player.skipToLive { finished in
                expect(finished).to(beTrue())
                done()
            }
            expect(skipped).to(beTrue())
        }

        expect(player.canSkipToLive()).toAlways(beFalse())
    }
}
