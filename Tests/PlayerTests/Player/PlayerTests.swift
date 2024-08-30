//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class PlayerTests: TestCase {
    func testDeallocation() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testTimesWhenEmpty() {
        let player = Player()
        expect(player.time()).toAlways(equal(.invalid), until: .seconds(1))
    }

    func testTimesInEmptyRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        player.play()
        expect(player.time()).toNever(equal(.invalid), until: .seconds(1))
    }

    func testTimesStayInRange() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        player.play()
        expect {
            let time = player.time()
            return player.seekableTimeRange.start <= time && time <= player.seekableTimeRange.end
        }
        .toAlways(beTrue(), until: .seconds(1))
    }

    func testMetadataUpdatesMustNotChangePlayerItem() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 1))
        expect(player.queuePlayer.currentItem?.url).toEventually(equal(Stream.onDemand.url))
        let currentItem = player.queuePlayer.currentItem
        expect(player.queuePlayer.currentItem).toAlways(equal(currentItem), until: .seconds(2))
    }

    func testRetrieveCurrentValueOnSubscription() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.properties.isBuffering).toEventually(beFalse())
        expectEqualPublished(
            values: [false],
            from: player.propertiesPublisher.slice(at: \.isBuffering),
            during: .seconds(1)
        )
    }

    func testPreloadedItems() {
        let player = Player(
            items: [
                .simple(url: Stream.onDemand.url),
                .simple(url: Stream.onDemand.url),
                .simple(url: Stream.onDemand.url)
            ]
        )
        let expectedResources: [Resource] = [
            .simple(url: Stream.onDemand.url),
            .simple(url: Stream.onDemand.url),
            .loading
        ]
        expect(player.items.map(\.content.resource)).toEventually(beSimilarTo(expectedResources))
        expect(player.items.map(\.content.resource)).toAlways(beSimilarTo(expectedResources), until: .seconds(1))
    }

    func testNoMetricsWhenFailed() {
        let player = Player(item: .failing(loadedAfter: 0.1))
        expect(player.properties.metrics()).toAlways(beNil(), until: .seconds(1))
    }
}
