//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class ItemNavigationSmartForwardTests: TestCase {
    @MainActor
    func testAdvanceForOnDemandWithNextItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testAdvanceForOnDemandWithoutNextItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testAdvanceForLiveWithNextItem() async {
        let item1 = PlayerItem.simple(url: Stream.live.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.streamType).toEventually(equal(.live))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testAdvanceForLiveWithoutNextItem() async {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.live))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testAdvanceForDvrWithNextItem() async {
        let item1 = PlayerItem.simple(url: Stream.dvr.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.streamType).toEventually(equal(.dvr))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testAdvanceForDvrWithoutNextItem() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item))
    }

    func testAdvanceForUnknownWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).to(equal(.unknown))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
    }

    func testAdvanceForUnknownWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).to(equal(.unknown))
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item))
    }
}
