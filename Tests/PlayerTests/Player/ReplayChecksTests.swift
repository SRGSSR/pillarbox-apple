//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class ReplayChecksTests: TestCase {
    @MainActor
    func testEmptyPlayer() {
        let player = Player()
        expect(player.canReplay()).to(beFalse())
    }

    @MainActor
    func testWithOneGoodItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.canReplay()).to(beFalse())
    }

    @MainActor
    func testWithOneGoodItemPlayedEntirely() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneBadItemConsumed() {
        // This item is consumed by the player when failing.
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneBadItemNotConsumed() {
        // This item is not consumed by the player when failing (for an unknown reason).
        let player = Player(item: .simple(url: Stream.unauthorized.url))
        expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithManyGoodItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.shortOnDemand.url)
        ])
        player.play()
        expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithManyBadItems() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneGoodItemAndOneBadItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneLongGoodItemAndOneBadItem() {
        let player = Player(items: [
            .simple(url: Stream.onDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        expect(player.canReplay()).toNever(beTrue(), until: .milliseconds(500))
    }
}
