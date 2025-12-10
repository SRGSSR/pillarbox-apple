//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class ReplayTests: TestCase {
    func testWithOneGoodItem() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        player.replay()
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testWithOneGoodItemPlayedEntirely() async {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        player.play()
        await expect(player.currentItem).toEventually(beNil())
        player.replay()
        await expect(player.currentItem).toEventually(equal(item))
    }

    @MainActor
    func testWithOneBadItem() async {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        await expect(player.currentItem).toAlways(equal(item), until: .milliseconds(500))
        player.replay()
        await expect(player.currentItem).toAlways(equal(item), until: .milliseconds(500))
    }

    @MainActor
    func testWithManyGoodItems() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        player.play()
        await expect(player.currentItem).toEventually(equal(item2))
        player.replay()
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testWithManyBadItems() async {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.play()
        await expect(player.currentItem).toAlways(equal(item1), until: .milliseconds(500))
        player.replay()
        await expect(player.currentItem).toAlways(equal(item1), until: .milliseconds(500))
    }

    @MainActor
    func testWithOneGoodItemAndOneBadItem() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.play()
        await expect(player.currentItem).toEventually(equal(item2))
        player.replay()
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testResumePlaybackIfNeeded() async {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        player.play()
        await expect(player.currentItem).toEventually(beNil())
        player.pause()
        player.replay()
        await expect(player.currentItem).toEventually(equal(item))
        await expect(player.playbackState).toEventually(equal(.playing))
    }
}
