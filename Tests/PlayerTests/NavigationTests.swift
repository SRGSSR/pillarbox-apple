//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class NavigationTests: XCTestCase {
    func testCanReturnForOnDemandAtBeginning() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
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

    func testCanReturnForUnknownItemWithPreviousItem() {

    }

    func testCannotReturnForUnknownItemWithoutPreviousItem() {

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

    func testCanAdvanceForUnknownItemWithNextItem() {

    }

    func testCannotAdvanceForUnknownItemWithoutNextItem() {

    }

    func testReturnForOnDemandAtBeginning() {

    }

    func testReturnForOnDemandNotAtBeginning() {

    }

    func testReturnForLiveWithPreviousItem() {

    }

    func testReturnForLiveWithoutPreviousItem() {

    }

    func testReturnForDvrWithPreviousItem() {

    }

    func testReturnForDvrWithoutPreviousItem() {

    }

    func testReturnForUnknownItemWithPreviousItem() {

    }

    func testReturnForUnknownItemWithoutPreviousItem() {

    }

    func testAdvanceForOnDemandWithNextItem() {

    }

    func testAdvanceForOnDemandWithoutNextItem() {

    }

    func testAdvanceForLiveWithNextItem() {

    }

    func testAdvanceForLiveWithoutNextItem() {

    }

    func testAdvanceForDvrWithNextItem() {

    }

    func testAdvanceForDvrWithoutNextItem() {

    }

    func testAdvanceForUnknownItemWithNextItem() {

    }

    func testAdvanceForUnknownItemWithoutNextItem() {

    }
}
