//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
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
        expect(player.time).toAlways(equal(.invalid), until: .seconds(1))
    }

    func testTimesInEmptyRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        player.play()
        expect(player.time).toNever(equal(.invalid), until: .seconds(1))
    }

    func testTimesStayInRange() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        player.play()
        expect {
            player.seekableTimeRange.start <= player.time && player.time <= player.seekableTimeRange.end
        }
        .toAlways(beTrue(), until: .seconds(1))
    }

    func testMetadataUpdatesMustNotChangePlayerItem() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 1))
        let publisher = player.queuePlayer.publisher(for: \.currentItem).compactMap(\.?.url)
        expectEqualPublishedNext(values: [Stream.onDemand.url], from: publisher, during: .seconds(2))
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

    func testNumberOfPreloadedItems() {
        let player = Player(
            items: [
                .simple(url: Stream.onDemand.url),
                .simple(url: Stream.onDemand.url),
                .simple(url: Stream.onDemand.url)
            ],
            configuration: .init(preloadedItems: 2)
        )
        let expectedResources: [Resource] = [
            .simple(url: Stream.onDemand.url),
            .simple(url: Stream.onDemand.url),
            .loading
        ]
        expect(player.items.map(\.asset.resource)).toEventually(beSimilarTo(expectedResources))
        expect(player.items.map(\.asset.resource)).toAlways(beSimilarTo(expectedResources), until: .seconds(1))
    }
}
