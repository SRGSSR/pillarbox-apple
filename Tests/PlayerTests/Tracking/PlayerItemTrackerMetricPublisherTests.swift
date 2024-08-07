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
            [.anyAssetLoading],
            [.anyAssetLoading, .anyResourceLoading],
            []
        ], from: player.metricEventsPublisher) {
            player.play()
        }
    }

    func testError() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectAtLeastSimilarPublished(values: [
            [],
            [.anyAssetLoading],
            [.anyAssetLoading, .anyFailure]
        ], from: player.metricEventsPublisher)
    }

    func testPlaylist() {
        let player = Player(items: [.simple(url: Stream.shortOnDemand.url), .simple(url: Stream.mediumOnDemand.url)])
        expectSimilarPublished(
            values: [
                [],
                [.anyAssetLoading],
                [.anyAssetLoading, .anyResourceLoading],
                [.anyAssetLoading, .anyResourceLoading]
            ],
            from: player.metricEventsPublisher,
            during: .milliseconds(1500)
        ) {
            player.play()
        }
    }
}
