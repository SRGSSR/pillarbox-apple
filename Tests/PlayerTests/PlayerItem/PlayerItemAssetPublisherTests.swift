//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemAssetPublisherTests: TestCase {
    func testNoLoad() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectAtLeastSimilarPublished(
            values: [.loading()],
            from: item.$content.map(\.resource)
        )
    }

    func testLoad() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectAtLeastSimilarPublished(
            values: [.loading(), .simple(url: Stream.onDemand.url)],
            from: item.$content.map(\.resource)
        ) {
            PlayerItem.load(for: item.id)
        }
    }

    func testReload() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectAtLeastSimilarPublished(
            values: [.loading(), .simple(url: Stream.onDemand.url)],
            from: item.$content.map(\.resource)
        ) {
            PlayerItem.load(for: item.id)
        }

        expectAtLeastSimilarPublished(
            values: [.simple(url: Stream.onDemand.url)],
            from: item.$content.map(\.resource)
        ) {
            PlayerItem.reload(for: item.id)
        }
    }
}
