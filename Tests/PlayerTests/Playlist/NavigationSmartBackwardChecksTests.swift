//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble
import Streams
import XCTest

final class NavigationSmartBackwardChecksTests: TestCase {
    func testCanReturnForOnDemandAtBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCanReturnForOnDemandNearBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCanReturnForOnDemandAtBeginningWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCanReturnForOnDemandNotAtBeginning() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 5, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCanReturnForLiveWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCannotReturnForLiveWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canReturnToPrevious()).to(beFalse())
    }

    func testCanReturnForDvrWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCannotReturnForDvrWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canReturnToPrevious()).to(beFalse())
    }

    func testCanReturnForUnknownWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).to(equal(.unknown))
        expect(player.canReturnToPrevious()).to(beTrue())
    }

    func testCannotReturnForUnknownWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).to(equal(.unknown))
        expect(player.canReturnToPrevious()).to(beFalse())
    }
}
