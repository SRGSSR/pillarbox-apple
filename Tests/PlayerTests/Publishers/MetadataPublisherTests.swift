//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import PillarboxCircumspect
import PillarboxStreams

final class MetadataPublisherTests: TestCase {
    private static func titlePublisherTest(for player: Player) -> AnyPublisher<String?, Never> {
        player.metadataPublisher.map(\.title).eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = Player()
        expectAtLeastEqualPublished(
            values: [nil],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testImmediatelyAvailableWithoutMetadata() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expectAtLeastEqualPublished(
            values: [nil],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testAvailableAfterDelay() {
        let player = Player(
            item: .playable(url: Stream.onDemand.url, metadata: .init(title: "title"), after: 0.1)
        )
        expectAtLeastEqualPublished(
            values: [nil, "title"],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testImmediatelyAvailableWithMetadata() {
        let player = Player(item: .playable(url: Stream.onDemand.url, metadata: .init(title: "title")))
        expectAtLeastEqualPublished(
            values: [nil, "title"],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testUpdate() {
        let player = Player(
            item: .playable(url: Stream.onDemand.url, metadata: .init(title: "title1"), updatedWithMetadata: .init(title: "title2"), interval: 0.1)
        )
        expectAtLeastEqualPublished(
            values: [nil, "title1", "title2"],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testNetworkItemReloading() {
        let player = Player(item: .playable(url: Stream.onDemand.url, metadata: .init(title: "title1"), after: 0.1))
        expectAtLeastEqualPublished(
            values: [nil, "title1"],
            from: Self.titlePublisherTest(for: player)
        )
        expectAtLeastEqualPublishedNext(
            values: [nil, "title2"],
            from: Self.titlePublisherTest(for: player)
        ) {
            player.items = [.playable(url: Stream.onDemand.url, metadata: .init(title: "title2"), after: 0.1)]
        }
    }

    func testEntirePlayback() {
        let player = Player(item: .playable(url: Stream.shortOnDemand.url, metadata: .init(title: "title")))
        expectAtLeastEqualPublished(
            values: [nil, "title", nil],
            from: Self.titlePublisherTest(for: player)
        ) {
            player.play()
        }
    }
}
