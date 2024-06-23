//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class SkipBackwardChecksTests: TestCase {
    @MainActor
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipBackward()).to(beFalse())
    }

    @MainActor
    func testCanSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipBackward()).to(beTrue())
    }

    @MainActor
    func testCannotSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipBackward()).to(beFalse())
    }

    @MainActor
    func testCanSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipBackward()).to(beTrue())
    }
}
