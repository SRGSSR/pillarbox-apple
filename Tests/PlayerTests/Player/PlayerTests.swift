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

private struct MockError: Error {}

final class PlayerTests: TestCase {
    func testDeallocation() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak let weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testEmptyPlayerChangeObservation() {
        let player = Player()
        expectChange(from: player) {
            player.togglePlayPause()
        }
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

    func testMetadataUpdatesMustNotChangePlayerItem() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 1))
        expect(player.queuePlayer.currentItem?.url).toEventually(equal(Stream.onDemand.url))
        let currentItem = player.queuePlayer.currentItem
        expect(player.queuePlayer.currentItem).toAlways(equal(currentItem), until: .seconds(2))
    }

    func testRetrieveCurrentValueOnSubscription() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.properties.isBuffering).toEventually(beFalse())
        expectAtLeastEqualPublished(
            values: [false],
            from: player.propertiesPublisher.slice(at: \.isBuffering)
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
            .loading()
        ]
        expect(player.items.map(\.content.resource)).toEventually(beSimilarTo(expectedResources))
        expect(player.items.map(\.content.resource)).toAlways(beSimilarTo(expectedResources), until: .seconds(1))
    }

    func testNoMetricsWhenFailed() {
        let player = Player(item: .failing(with: MockError(), after: 0.1))
        expect(player.metrics()).toAlways(beNil(), until: .seconds(1))
    }
}
