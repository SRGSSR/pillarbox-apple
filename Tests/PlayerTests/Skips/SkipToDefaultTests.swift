//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class SkipToDefaultTests: TestCase {
    func testSkipWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.invalid))
                done()
            }
        }
    }

    func testSkipForUnknown() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.streamType).toEventually(equal(.unknown))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.invalid))
                done()
            }
        }
    }

    func testSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.zero))
                done()
            }
        }
    }

    func testSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForDvrInLiveConditions() {
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

    func testSkipForDvrInPastConditions() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { finished in
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
    }
}
