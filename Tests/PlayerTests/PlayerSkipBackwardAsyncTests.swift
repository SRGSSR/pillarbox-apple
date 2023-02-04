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

final class PlayerSkipBackwardAsyncTests: XCTestCase {
    func testSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await expect(player.time).to(equal(.zero))
        await expect(await player.skipBackward()).to(beTrue())
        await expect(player.time).to(equal(.zero))
    }

    func testMultipleSkipsForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await expect(player.time).to(equal(.zero))
        async let finished1 = await player.skipBackward()
        async let finished2 = await player.skipBackward()
        let finished = await (finished1, finished2)
        await expect(finished.0).to(beFalse())
        await expect(finished.1).to(beTrue())
        await expect(player.time).to(equal(.zero))
    }

    func testSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        await expect(await player.skipBackward()).to(beFalse())
    }

    func testSkipForDvr() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time
        await expect(await player.skipBackward()).to(beTrue())
        await expect(player.time).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
    }
}
