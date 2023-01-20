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

final class NavigationTests: XCTestCase {
    func testCanReturnForOnDemandAtBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
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
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(to: CMTime(value: 5, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
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

    func testCanAdvanceForOnDemandWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canAdvanceToNext()).to(beTrue())
    }

    func testCannotAdvanceForOnDemandWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canAdvanceToNext()).to(beFalse())
    }

    func testCanAdvanceForLiveWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.live.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canAdvanceToNext()).to(beTrue())
    }

    func testCannotAdvanceForLiveWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canAdvanceToNext()).to(beFalse())
    }

    func testCanAdvanceForDvrWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.dvr.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canAdvanceToNext()).to(beTrue())
    }

    func testCannotAdvanceForDvrWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canAdvanceToNext()).to(beFalse())
    }

    func testCanAdvanceForUnknownWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).to(equal(.unknown))
        expect(player.canAdvanceToNext()).to(beTrue())
    }

    func testCannotAdvanceForUnknownWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).to(equal(.unknown))
        expect(player.canAdvanceToNext()).to(beFalse())
    }

    func testReturnForOnDemandAtBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForOnDemandAtBeginningWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForOnDemandNotAtBeginning() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(to: CMTime(value: 5, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                done()
            }
        }
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
        expect(player.time).toEventually(equal(.zero), timeout: .seconds(3))
    }

    func testReturnForLiveWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForLiveWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForDvrWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForDvrWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForUnknownWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForUnknownWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForOnDemandWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForOnDemandWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForLiveWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.live.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.live))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForLiveWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForDvrWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.dvr.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.dvr))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForDvrWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForUnknownWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).to(equal(.unknown))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForUnknownWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).to(equal(.unknown))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }
}
