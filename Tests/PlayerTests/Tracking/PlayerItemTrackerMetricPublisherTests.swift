//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerMetricPublisherTests: TestCase {
    func testEmptyPlayer() {
        let player = Player()
        expectSimilarPublished(values: [[]], from: player.metricEventsPublisher, during: .milliseconds(500))
    }

    func testItemPlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastSimilarPublished(values: [
            [],
            [.anyMetadata],
            [.anyMetadata, .anyAsset],
            []
        ], from: player.metricEventsPublisher) {
            player.play()
        }
    }

    func testError() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectAtLeastSimilarPublished(values: [
            [],
            [.anyMetadata],
            [.anyMetadata, .anyFailure]
        ], from: player.metricEventsPublisher)
    }

    func testPlaylist() {
        let player = Player(items: [.simple(url: Stream.shortOnDemand.url), .simple(url: Stream.mediumOnDemand.url)])
        expectSimilarPublished(
            values: [
                [],
                [.anyMetadata],
                [.anyMetadata, .anyAsset],
                [.anyMetadata, .anyAsset]
            ],
            from: player.metricEventsPublisher,
            during: .seconds(2)
        ) {
            player.play()
        }
    }
}
