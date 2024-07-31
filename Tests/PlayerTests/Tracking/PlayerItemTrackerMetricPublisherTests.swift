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
    private static let assetLoading: MetricEvent = .init(kind: .assetLoading(.init()))
    private static let resourceLoading: MetricEvent = .init(kind: .resourceLoading(.init()))
    private static let anyFailure: MetricEvent = .init(kind: .anyFailure)

    func testEmptyPlayer() {
        let player = Player()
        expectNothingPublished(from: player.tracker.metricEventsPublisher, during: .milliseconds(100))
    }

    func testNotEmptyPlayer() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastSimilarPublished(values: [
            [Self.assetLoading],
            [Self.assetLoading, Self.resourceLoading]
        ], from: player.tracker.metricEventsPublisher)
    }

    func testError() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectAtLeastSimilarPublished(values: [
            [Self.assetLoading],
            [Self.assetLoading, Self.anyFailure]
        ], from: player.tracker.metricEventsPublisher)
    }

    func testReplay() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectSimilarPublished(
            values: [
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading],
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading]
            ],
            from: player.tracker.metricEventsPublisher,
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
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading],
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading]
            ],
            from: player.tracker.metricEventsPublisher,
            during: .milliseconds(1500)
        ) {
            player.play()
        }
    }

    func testPlaylistWithError() {
        let player = Player(items: [.simple(url: Stream.shortOnDemand.url), .simple(url: Stream.unauthorized.url)])
        expectSimilarPublished(
            values: [
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading],
                [Self.assetLoading],
                [Self.assetLoading, Self.anyFailure]
            ],
            from: player.tracker.metricEventsPublisher,
            during: .milliseconds(1500)
        ) {
            player.play()
        }
    }
}
