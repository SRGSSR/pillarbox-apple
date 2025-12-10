//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class SkipToDefaultChecksTests: TestCase {
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipToDefault()).to(beFalse())
    }

    @MainActor
    func testCannotSkipForUnknown() async {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.streamType).toEventually(equal(.unknown))
        expect(player.canSkipToDefault()).to(beFalse())
    }

    @MainActor
    func testCanSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipToDefault()).to(beTrue())
    }

    @MainActor
    func testCannotSkipForDvrInLiveConditions() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipToDefault()).to(beFalse())
    }

    @MainActor
    func testCanSkipForDvrInPastConditions() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))

        await waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.canSkipToDefault()).to(beTrue())
    }

    @MainActor
    func testCanSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipToDefault()).to(beTrue())
    }
}
