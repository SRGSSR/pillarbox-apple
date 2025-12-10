//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class SkipBackwardTests: TestCase {
    @MainActor
    func testSkipWhenEmpty() async {
        let player = Player()
        await waitUntil { done in
            player.skipBackward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        await waitUntil { done in
            player.skipBackward { _ in
                expect(player.time()).to(equal(.zero))
                done()
            }
        }
    }

    @MainActor
    func testMultipleSkipsForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        await waitUntil { done in
            player.skipBackward { finished in
                expect(finished).to(beFalse())
            }

            player.skipBackward { finished in
                expect(player.time()).to(equal(.zero))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        await waitUntil { done in
            player.skipBackward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForDvr() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time()
        await waitUntil { done in
            player.skipBackward { finished in
                expect(player.time()).to(equal(headTime + player.backwardSkipTime, by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }
}
