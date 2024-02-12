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
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.replay()
        expect(player.currentIndex).to(equal(0))
    }

    func testWithOneGoodItemPlayedEntirely() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.currentIndex).toEventually(beNil())
        player.replay()
        expect(player.currentIndex).toEventually(equal(0))
    }

    func testWithOneBadItem() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.currentIndex).toAlways(equal(0), until: .milliseconds(500))
        player.replay()
        expect(player.currentIndex).toAlways(equal(0), until: .milliseconds(500))
    }

    func testWithManyGoodItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.shortOnDemand.url)
        ])
        player.play()
        expect(player.currentIndex).toEventually(equal(1))
        player.replay()
        expect(player.currentIndex).to(equal(1))
    }

    func testWithManyBadItems() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.currentIndex).toAlways(equal(0), until: .milliseconds(500))
        player.replay()
        expect(player.currentIndex).toAlways(equal(0), until: .milliseconds(500))
    }

    func testWithOneGoodItemAndOneBadItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.currentIndex).toEventually(equal(1))
        player.replay()
        expect(player.currentIndex).to(equal(1))
    }

    func testResumePlaybackIfNeeded() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.currentIndex).toEventually(beNil())
        player.pause()
        player.replay()
        expect(player.currentIndex).toEventually(equal(0))
        expect(player.playbackState).toEventually(equal(.playing))
    }
}
