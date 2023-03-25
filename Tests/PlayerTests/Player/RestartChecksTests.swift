//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation
import Nimble

final class RestartChecksTests: TestCase {
    func testEmptyPlayer() {
        let player = Player()
        expect(player.canRestart()).to(beFalse())
    }

    func testWithOneGoodItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.canRestart()).to(beFalse())
    }

    func testWithOneGoodItemPlayedEntirely() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.canRestart()).toEventually(beTrue())
    }

    func testWithOneBadItem() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.canRestart()).toEventually(beTrue())
    }

    func testWithManyGoodItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.shortOnDemand.url)
        ])
        player.play()
        expect(player.canRestart()).toEventually(beTrue())
    }

    func testWithManyBadItems() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.canRestart()).toEventually(beTrue())
    }

    func testWithOneGoodItemAndOneBadItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.canRestart()).toEventually(beTrue())
    }
}
