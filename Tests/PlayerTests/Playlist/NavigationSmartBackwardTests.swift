//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class NavigationSmartBackwardTests: TestCase {
    @MainActor
    func testReturnForOnDemandAtBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForOnDemandNearBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
        expect(player.time).toEventually(equal(.zero))
    }

    @MainActor
    func testReturnForOnDemandAtBeginningWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForOnDemandNotAtBeginning() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 5, timescale: 1))) { _ in
                done()
            }
        }
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(1))
        expect(player.time).toEventually(equal(.zero))
    }

    @MainActor
    func testReturnForLiveWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForLiveWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForDvrWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForDvrWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForUnknownWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReturnForUnknownWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }
}
