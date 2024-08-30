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
    func testSkipWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.skipBackward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        waitUntil { done in
            player.skipBackward { _ in
                expect(player.time()).to(equal(.zero))
                done()
            }
        }
    }

    func testMultipleSkipsForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        waitUntil { done in
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

    func testSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.skipBackward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time()
        waitUntil { done in
            player.skipBackward { finished in
                expect(player.time()).to(equal(headTime + player.backwardSkipTime, by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }
}
