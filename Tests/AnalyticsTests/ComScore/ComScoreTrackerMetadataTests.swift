//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import ComScore
import CoreMedia
import Nimble
import Player
import Streams
import XCTest

private struct AssetMetadataMock: AssetMetadata {}

final class ComScoreTrackerMetadataTests: ComScoreTestCase {
    func testMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in
                    [
                        "meta_1": "custom-1",
                        "meta_2": "42"
                    ]
                }
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.extract("meta_1")).to(equal("custom-1"))
                expect(labels.extract("meta_2")).to(equal(42))
            }
        ) {
            player.play()
        }
    }

    func testEmptyMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in
                    [:]
                }
            ]
        ))

        expectNoEvents(during: .seconds(3)) {
            player.play()
        }
    }

    func testNoMetadata() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expectNoEvents(during: .seconds(3)) {
            player.play()
        }
    }
}
