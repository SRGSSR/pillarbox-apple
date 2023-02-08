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

final class PlayerSkipForwardTests: XCTestCase {
    func testSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))

        waitUntil { done in
            player.skipForward { _ in
                expect(player.time).to(equal(player.forwardSkipTime, by: beClose(within: player.chunkDuration.seconds)))
                done()
            }
        }
    }

    func testMultipleSkipsForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time).to(equal(.zero))

        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beFalse())
            }

            player.skipForward { finished in
                expect(player.time).to(equal(CMTimeMultiply(player.forwardSkipTime, multiplier: 2), by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time
        waitUntil { done in
            player.skipForward { finished in
                expect(player.time).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }
}
