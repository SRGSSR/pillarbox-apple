//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation
import Nimble

final class PlayerRestartTests: TestCase {
    func testWithOneGoodItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.restart()
        expect(player.currentIndex).to(equal(0))
    }

    func testWithOneGoodItemEnded() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.currentIndex).toEventually(beNil())
        player.restart()
        expect(player.currentIndex).toEventually(equal(0))
    }

    func testWithOneBadItem() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.currentIndex).toEventually(beNil())
        player.restart()
        expect(player.currentIndex).toEventually(equal(0))
    }

    func testWithManyGoodItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.shortOnDemand.url)
        ])
        player.play()
        expect(player.currentIndex).toEventually(equal(1))
        player.restart()
        expect(player.currentIndex).to(equal(1))
    }

    func testWithManyBadItems() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.currentIndex).toEventually(beNil())
        player.restart()
        expect(player.currentIndex).to(equal(0))
    }

    func testWithOneGoodItemAndOneBadItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.currentIndex).toEventually(beNil())
        player.restart()
        expect(player.currentIndex).to(equal(0))
    }
}
