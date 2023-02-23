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

final class PlayerSkipToDefaultChecksTests: XCTestCase {
    func testCannotSkipToDefaultWhenEmpty() {
        let player = Player()
        expect(player.canSkipToDefault()).to(beFalse())
    }

    func testCannotSkipToDefaultWhenUnknown() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.streamType).toEventually(equal(.unknown))
        expect(player.canSkipToDefault()).to(beFalse())
    }

    func testCanSkipToDefaultWhenOnDemand() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipToDefault()).to(beTrue())
    }

    func testCannotSeekToDefaultForDvrInLiveConditions() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipToDefault()).to(beFalse())
    }

    func testCanSeekToDefaultForDvrInPastConditions() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                done()
            }
        }

        expect(player.canSkipToDefault()).to(beTrue())
    }

    func testCanSkipToDefaultWhenLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipToDefault()).to(beFalse())
    }
}
