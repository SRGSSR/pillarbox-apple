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
        expectNothingPublished(from: player.metricEventsPublisher, during: .milliseconds(100))
    }

    func testNotEmptyPlayer() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastSimilarPublished(values: [
            [.anyAssetLoading],
            [.anyAssetLoading, .anyResourceLoading]
        ], from: player.metricEventsPublisher)
    }

    func testError() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectAtLeastSimilarPublished(values: [
            [.anyAssetLoading],
            [.anyAssetLoading, .anyFailure]
        ], from: player.metricEventsPublisher)
    }

    func testReplay() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectSimilarPublished(
            values: [
                [.anyAssetLoading],
                [.anyAssetLoading, .anyResourceLoading],
                [.anyAssetLoading],
                [.anyAssetLoading, .anyResourceLoading]
            ],
            from: player.metricEventsPublisher,
            during: .milliseconds(1500)
        ) {
            player.play()
            expect(player.playbackState).toEventually(equal(.playing))
            expect(player.playbackState).toEventually(equal(.idle))
            player.replay()
        }
    }

    func testPlaylist() {
        let player = Player(items: [.simple(url: Stream.shortOnDemand.url), .simple(url: Stream.mediumOnDemand.url)])
        expectSimilarPublished(
            values: [
                [.anyAssetLoading],
                [.anyAssetLoading, .anyResourceLoading],
                [.anyAssetLoading],
                [.anyAssetLoading, .anyResourceLoading]
            ],
            from: player.metricEventsPublisher,
            during: .milliseconds(1500)
        ) {
            player.play()
        }
    }

    func testPlaylistWithError() {
        let player = Player(items: [.simple(url: Stream.shortOnDemand.url), .simple(url: Stream.unauthorized.url)])
        expectSimilarPublished(
            values: [
                [.anyAssetLoading],
                [.anyAssetLoading, .anyResourceLoading],
                [.anyAssetLoading],
                [.anyAssetLoading, .anyFailure]
            ],
            from: player.metricEventsPublisher,
            during: .milliseconds(1500)
        ) {
            player.play()
        }
    }
}
