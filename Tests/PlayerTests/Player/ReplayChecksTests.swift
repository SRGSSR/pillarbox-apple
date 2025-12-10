//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class ReplayChecksTests: TestCase {
    func testEmptyPlayer() {
        let player = Player()
        expect(player.canReplay()).to(beFalse())
    }

    func testWithOneGoodItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.canReplay()).to(beFalse())
    }

    @MainActor
    func testWithOneGoodItemPlayedEntirely() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        await expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneBadItemConsumed() async {
        // This item is consumed by the player when failing.
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneBadItemNotConsumed() async {
        // This item is not consumed by the player when failing (for an unknown reason).
        let player = Player(item: .simple(url: Stream.unauthorized.url))
        await expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithManyGoodItems() async {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.shortOnDemand.url)
        ])
        player.play()
        await expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithManyBadItems() async {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        await expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneGoodItemAndOneBadItem() async {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        await expect(player.canReplay()).toEventually(beTrue())
    }

    @MainActor
    func testWithOneLongGoodItemAndOneBadItem() async {
        let player = Player(items: [
            .simple(url: Stream.onDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        player.play()
        await expect(player.canReplay()).toNever(beTrue(), until: .milliseconds(500))
    }
}
