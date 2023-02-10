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

final class PlayerSkipToLiveTests: XCTestCase {
    func testSkipToLiveWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.skipToLive { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipToLiveWhenEmptyAsync() async {
        let player = Player()
        await expect { await player.skipToLive() }.to(beTrue())
    }

    func testSkipToLiveForOnDemand() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.skipToLive { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipToLiveForLive() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.skipToLive { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipToLiveForDvrInLiveConditions() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        waitUntil { done in
            player.skipToLive { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipToLiveForDvrInPastConditions() {
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
            player.skipToLive { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        expect(player.canSkipToLive()).toAlways(beFalse())
        expect(player.playbackState).to(equal(.playing))
    }

    func testSkipToLiveForDvrInPastConditionsAsync() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))
        let seeked = await player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        expect(seeked).to(beTrue())
        await expect { await player.skipToLive() }.to(beTrue())
        await expect(player.canSkipToLive()).toAlways(beFalse())
        expect(player.playbackState).to(equal(.playing))
    }
}
