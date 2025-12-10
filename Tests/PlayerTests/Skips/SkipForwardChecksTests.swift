//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class SkipForwardChecksTests: TestCase {
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipForward()).to(beFalse())
    }

    @MainActor
    func testCanSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipForward()).to(beTrue())
    }

    @MainActor
    func testCannotSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipForward()).to(beFalse())
    }

    @MainActor
    func testCannotSkipForDvr() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipForward()).to(beFalse())
    }
}
