//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class PlayerSkipToDefaultTests: XCTestCase {
    func testSkipToDefaultWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(.invalid))
                done()
            }
        }
    }

    func testSkipToDefaultForUnknown() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.streamType).toEventually(equal(.unknown))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(.invalid))
                done()
            }
        }
    }

    func testSkipToDefaultForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(.zero))
                done()
            }
        }
    }

    func testSkipToDefaultForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(Stream.live.duration))
                done()
            }
        }
    }

    func testSkipToDefaultForDvrInLiveConditions() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipToDefaultForDvrInPastConditions() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        expect(player.canSkipToDefault()).toAlways(beFalse())
    }
}
