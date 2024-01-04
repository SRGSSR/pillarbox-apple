//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class NavigationSmartForwardTests: TestCase {
    func testAdvanceForOnDemandWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForOnDemandWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForLiveWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.live.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.live))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForLiveWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForDvrWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.dvr.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.dvr))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForDvrWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }

    func testAdvanceForUnknownWithNextItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).to(equal(.unknown))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(1))
    }

    func testAdvanceForUnknownWithoutNextItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).to(equal(.unknown))
        player.advanceToNext()
        expect(player.currentIndex).to(equal(0))
    }
}
