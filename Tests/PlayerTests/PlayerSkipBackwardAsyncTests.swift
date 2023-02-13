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
    func testSkipWhenEmptyAsync() async {
        let player = Player()
        await expect { await player.skipBackward() }.to(beTrue())
    }

    func testSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))
        await expect { await player.skipBackward() }.to(beTrue())
        expect(player.time).to(equal(.zero))
    }

    func testMultipleSkipsForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))
        async let finished1 = player.skipBackward()
        async let finished2 = player.skipBackward()
        let finished = await (finished1, finished2)
        expect(finished.0).to(beFalse())
        expect(finished.1).to(beTrue())
        expect(player.time).to(equal(.zero))
    }

    func testSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        let headTime = player.time
        await expect { await player.skipBackward() }.to(beTrue())
        expect(player.time).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
    }

    func testSkipForDvr() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time
        await expect { await player.skipBackward() }.to(beTrue())
        expect(player.time).to(equal(headTime + player.backwardSkipTime, by: beClose(within: player.chunkDuration.seconds)))
    }
}
