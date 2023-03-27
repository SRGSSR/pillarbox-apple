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

final class SkipToDefaultChecksTests: TestCase {
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipToDefault()).to(beFalse())
    }

    func testCannotSkipForUnknown() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.streamType).toEventually(equal(.unknown))
        expect(player.canSkipToDefault()).to(beFalse())
    }

    func testCanSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipToDefault()).to(beTrue())
    }

    func testCannotSkipForDvrInLiveConditions() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipToDefault()).to(beFalse())
    }

    func testCanSkipForDvrInPastConditions() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.canSkipToDefault()).to(beTrue())
    }

    func testCanSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipToDefault()).to(beTrue())
    }
}
