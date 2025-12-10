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
    @MainActor
    func testSkipWhenEmpty() async {
        let player = Player()
        await waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.invalid))
                done()
            }
        }
    }

    @MainActor
    func testSkipForUnknown() async {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.streamType).toEventually(equal(.unknown))
        await waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.zero))
                done()
            }
        }
    }

    @MainActor
    func testSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.zero))
                done()
            }
        }
    }

    @MainActor
    func testSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        await waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForDvrInLiveConditions() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))
        await waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForDvrInPastConditions() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))

        await waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        await waitUntil { done in
            player.skipToDefault { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }
}
