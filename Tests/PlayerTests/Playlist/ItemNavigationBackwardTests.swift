//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class ItemNavigationBackwardTests: TestCase {
    private static func configuration() -> PlayerConfiguration {
        .init(navigationMode: .immediate)
    }

    func testReturnToPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnToPreviousItemAtFront() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnToPreviousItemOnFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    func testWrapAtFrontWithRepeatAll() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.repeatMode = .all
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testReturnForOnDemandAtBeginningWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item, configuration: Self.configuration())
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testReturnForOnDemandNearBeginningWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item, configuration: Self.configuration())
        await expect(player.streamType).toEventually(equal(.onDemand))

        await waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
        await expect(player.time()).toNever(equal(.zero), until: .seconds(3))
    }

    @MainActor
    func testReturnForOnDemandAtBeginningWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testReturnForOnDemandNotAtBeginning() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.onDemand))

        await waitUntil { done in
            player.seek(at(CMTime(value: 5, timescale: 1))) { _ in
                done()
            }
        }
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
        await expect(player.time()).toEventually(equal(.zero))
    }

    @MainActor
    func testReturnForLiveWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testReturnForLiveWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item, configuration: Self.configuration())
        await expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testReturnForDvrWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testReturnForDvrWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item, configuration: Self.configuration())
        await expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testReturnForUnknownWithPreviousItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        await expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testReturnForUnknownWithoutPreviousItem() async {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item, configuration: Self.configuration())
        await expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item))
    }

    func testPlayerPreloadedItemCount() {
        let player = Player(items: [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.squareOnDemand.url),
            PlayerItem.simple(url: Stream.mediumOnDemand.url),
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url)
        ])
        player.advanceToNextItem()
        player.returnToPreviousItem()

        let items = player.queuePlayer.items()
        expect(items).to(haveCount(player.configuration.preloadedItems))
    }
}
