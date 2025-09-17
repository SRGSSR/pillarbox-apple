//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class ItemNavigationBackwardChecksTests: TestCase {
    private static func configuration() -> PlayerConfiguration {
        .init(navigationMode: .immediate)
    }

    func testCanReturnToPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnToPreviousItemAtFront() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCannotReturnToPreviousItemWhenEmpty() {
        let player = Player()
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testWrapAtFrontWithRepeatAll() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.repeatMode = .all
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnForOnDemandAtBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCanReturnForOnDemandNearBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCanReturnForOnDemandAtBeginningWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCanReturnForOnDemandNotAtBeginning() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 5, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCanReturnForLiveWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnForLiveWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCanReturnForDvrWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnForDvrWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCanReturnForUnknownWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).to(equal(.unknown))
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnForUnknownWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).to(equal(.unknown))
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }
}
