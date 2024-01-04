//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class NavigationBackwardTests: TestCase {
    private static func configuration() -> PlayerConfiguration {
        .init(smartNavigationEnabled: false)
    }

    func testReturnForOnDemandAtBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForOnDemandNearBeginningWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
        expect(player.time).toNever(equal(.zero), until: .seconds(3))
    }

    func testReturnForOnDemandAtBeginningWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForOnDemandNotAtBeginning() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))

        waitUntil { done in
            player.seek(at(CMTime(value: 5, timescale: 1))) { _ in
                done()
            }
        }
        player.returnToPrevious()
        expect(player.currentIndex).to(equal(0))
        expect(player.time).toEventually(equal(.zero))
    }

    func testReturnForLiveWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForLiveWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.live.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.live))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForDvrWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForDvrWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.dvr))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForUnknownWithPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2], configuration: Self.configuration())
        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnForUnknownWithoutPreviousItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item, configuration: Self.configuration())
        expect(player.streamType).toEventually(equal(.unknown))
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }
}
