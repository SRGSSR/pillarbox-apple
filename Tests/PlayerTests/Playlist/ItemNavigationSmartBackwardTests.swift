//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

@MainActor
final class ItemNavigationSmartBackwardTests: TestCase {
    func testReturnForOnDemandAtBeginningWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    func testReturnForOnDemandNearBeginningWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.onDemand))

        await waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
        await expect(player.time()).toEventually(equal(.zero))
    }

    func testReturnForOnDemandAtBeginningWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnForOnDemandNotAtBeginning() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.onDemand))

        await waitUntil { done in
            player.seek(at(CMTime(value: 5, timescale: 1))) { _ in
                done()
            }
        }
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item2))
        await expect(player.time()).toEventually(equal(.zero))
    }

    func testReturnForLiveWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnForLiveWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    func testReturnForDvrWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnForDvrWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    func testReturnForUnknownWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnForUnknownWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }
}
