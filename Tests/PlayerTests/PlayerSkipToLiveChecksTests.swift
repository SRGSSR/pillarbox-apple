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

final class PlayerSkipToLiveChecksTests: XCTestCase {
    func testCannotSkipToLiveWhenEmpty() {
        let player = Player()
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCannotSkipToLiveForOnDemand() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCannotSkipToLiveForLive() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCannotSkipToLiveForDvrInLiveConditions() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canSkipToLive()).toAlways(beFalse())
    }

    func testCanSkipToLiveForDvrInPastConditions() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        expect(player.canSkipToLive()).toAlways(beTrue())
    }

    func testCanSkipToLiveForDvrInPastConditionsAsync() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))
        let seeked = await player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        expect(seeked).to(beTrue())
        await expect(player.canSkipToLive()).toAlways(beTrue())
    }
}
