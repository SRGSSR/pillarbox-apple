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

    func testReplayContent() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectSimilarPublished(
            values: [
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading],
                [Self.assetLoading],
                [Self.assetLoading, Self.resourceLoading]
            ],
            from: player.tracker.metricEventsPublisher,
            during: .seconds(2)
        ) {
            player.play()
            expect(player.playbackState).toEventually(equal(.playing))
            expect(player.playbackState).toEventually(equal(.idle))
            player.replay()
        }
    }
}
