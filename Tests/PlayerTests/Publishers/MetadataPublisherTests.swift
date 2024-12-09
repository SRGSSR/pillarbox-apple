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
            item: .mock(url: Stream.onDemand.url, loadedAfter: 0.1, withMetadata: AssetMetadataMock(title: "title"))
        )
        expectAtLeastEqualPublished(
            values: [nil, "title"],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testImmediatelyAvailableWithMetadata() {
        let player = Player(item: .mock(
            url: Stream.onDemand.url,
            loadedAfter: 0,
            withMetadata: AssetMetadataMock(title: "title")
        ))
        expectAtLeastEqualPublished(
            values: [nil, "title"],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testUpdate() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 0.1))
        expectAtLeastEqualPublished(
            values: [nil, "title0", "title1"],
            from: Self.titlePublisherTest(for: player)
        )
    }

    func testNetworkItemReloading() {
        let player = Player(item: .webServiceMock(media: .media1))
        expectAtLeastEqualPublished(
            values: [nil, "Title 1"],
            from: Self.titlePublisherTest(for: player)
        )
        expectAtLeastEqualPublishedNext(
            values: [nil, "Title 2"],
            from: Self.titlePublisherTest(for: player)
        ) {
            player.items = [.webServiceMock(media: .media2)]
        }
    }

    func testEntirePlayback() {
        let player = Player(item: .mock(url: Stream.shortOnDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastEqualPublished(
            values: [nil, "title", nil],
            from: Self.titlePublisherTest(for: player)
        ) {
            player.play()
        }
    }
}
