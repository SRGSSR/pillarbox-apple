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

        weak var weakPlayer = player
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

    @MainActor
    func testTimesWhenEmpty() async {
        let player = Player()
        await expect(player.time()).toAlways(equal(.invalid), until: .seconds(1))
    }

    @MainActor
    func testTimesInEmptyRange() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        player.play()
        await expect(player.time()).toNever(equal(.invalid), until: .seconds(1))
    }

    @MainActor
    func testMetadataUpdatesMustNotChangePlayerItem() async {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 1))
        await expect(player.queuePlayer.currentItem?.url).toEventually(equal(Stream.onDemand.url))
        let currentItem = player.queuePlayer.currentItem
        await expect(player.queuePlayer.currentItem).toAlways(equal(currentItem), until: .seconds(2))
    }

    @MainActor
    func testRetrieveCurrentValueOnSubscription() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.properties.isBuffering).toEventually(beFalse())
        expectAtLeastEqualPublished(
            values: [false],
            from: player.propertiesPublisher.slice(at: \.isBuffering)
        )
    }

    @MainActor
    func testPreloadedItems() async {
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
        await expect(player.items.map(\.content.resource)).toEventually(beSimilarTo(expectedResources))
        await expect(player.items.map(\.content.resource)).toAlways(beSimilarTo(expectedResources), until: .seconds(1))
    }

    @MainActor
    func testNoMetricsWhenFailed() async {
        let player = Player(item: .failing(with: MockError(), after: 0.1))
        await expect(player.metrics()).toAlways(beNil(), until: .seconds(1))
    }
}
