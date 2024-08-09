//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble
import PillarboxPlayer
import PillarboxStreams

final class ComScoreTrackerMetadataTests: ComScoreTestCase {
    func testMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in
                    ["meta_1": "custom-1", "meta_2": "42"]
                }
            ]
        ))

        expectAtLeastHits(
            play { labels in
                expect(labels["meta_1"]).to(equal("custom-1"))
                expect(labels["meta_2"]).to(equal(42))
                expect(labels["cs_ucfr"]).to(beEmpty())
            }
        ) {
            player.play()
        }
    }

    func testEmptyMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in [:] }
            ]
        ))

        expectNoHits(during: .seconds(3)) {
            player.play()
        }
    }

    func testNoMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in [:] }
            ]
        ))

        expectNoHits(during: .seconds(3)) {
            player.play()
        }
    }
}
