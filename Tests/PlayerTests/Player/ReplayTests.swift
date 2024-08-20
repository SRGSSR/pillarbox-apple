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

    func testWithOneGoodItemPlayedEntirely() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        player.play()
        expect(player.currentItem).toEventually(beNil())
        player.replay()
        expect(player.currentItem).toEventually(equal(item))
    }

    func testWithOneBadItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.currentItem).toAlways(equal(item), until: .milliseconds(500))
        player.replay()
        expect(player.currentItem).toAlways(equal(item), until: .milliseconds(500))
    }

    func testWithManyGoodItems() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        player.play()
        expect(player.currentItem).toEventually(equal(item2))
        player.replay()
        expect(player.currentItem).to(equal(item2))
    }

    func testWithManyBadItems() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.play()
        expect(player.currentItem).toAlways(equal(item1), until: .milliseconds(500))
        player.replay()
        expect(player.currentItem).toAlways(equal(item1), until: .milliseconds(500))
    }

    func testWithOneGoodItemAndOneBadItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.play()
        expect(player.currentItem).toEventually(equal(item2))
        player.replay()
        expect(player.currentItem).to(equal(item2))
    }

    func testResumePlaybackIfNeeded() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        player.play()
        expect(player.currentItem).toEventually(beNil())
        player.pause()
        player.replay()
        expect(player.currentItem).toEventually(equal(item))
        expect(player.playbackState).toEventually(equal(.playing))
    }
}
