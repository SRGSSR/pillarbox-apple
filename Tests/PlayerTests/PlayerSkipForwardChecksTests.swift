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

final class PlayerSkipForwardChecksTests: XCTestCase {
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
        expect(player.canSkipForward()).to(beFalse())
    }
}
