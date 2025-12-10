//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class ItemNavigationForwardChecksTests: TestCase {
    func testCanAdvanceToNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    func testCannotAdvanceToNextItemAtBack() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testCannotAdvanceToNextItemWhenEmpty() {
        let player = Player()
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testWrapAtBackWithRepeatAll() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.repeatMode = .all
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    @MainActor
    func testCanAdvanceForOnDemandWithNextItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    @MainActor
    func testCannotAdvanceForOnDemandWithoutNextItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    @MainActor
    func testCanAdvanceForLiveWithNextItem() async {
        let item1 = PlayerItem.simple(url: Stream.live.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.streamType).toEventually(equal(.live))
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    @MainActor
    func testCannotAdvanceForLiveWithoutNextItem() async {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.live))
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    @MainActor
    func testCanAdvanceForDvrWithNextItem() async {
        let item1 = PlayerItem.simple(url: Stream.dvr.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    @MainActor
    func testCannotAdvanceForDvrWithoutNextItem() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        await expect(player.streamType).toEventually(equal(.dvr))
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testCanAdvanceForUnknownWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).to(equal(.unknown))
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    func testCannotAdvanceForUnknownWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).to(equal(.unknown))
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }
}
