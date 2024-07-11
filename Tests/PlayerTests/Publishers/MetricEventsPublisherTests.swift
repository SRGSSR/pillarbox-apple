//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import Nimble
import PillarboxCircumspect
import PillarboxStreams

private struct MockedError: Error {}

final class MetricEventsPublisherTests: TestCase {
    func testEmpty() {
        let player = Player()
        expectNothingPublished(from: player.metricEventsPublisher, during: .milliseconds(500))
    }

    func testPlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .resourceLoading(.init()))]
            ],
            from: player.metricEventsPublisher
        )
    }

    func testAssetFailure() {
        let publisher = Fail<Asset<Void>, Error>(error: MockedError())
        let player = Player(item: .init(publisher: publisher))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .failure(error: MockedError(), level: .fatal))]
            ],
            from: player.metricEventsPublisher
        )
    }

    func testPlaybackFailure() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .failure(error: MockedError(), level: .fatal))]
            ],
            from: player.metricEventsPublisher
        )
    }

    func testPlaylistTransition() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.onDemand.url)
        ])
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .resourceLoading(.init()))],
                [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))]
            ],
            from: player.metricEventsPublisher
        ) {
            player.play()
        }
    }

    func testPlaylistTransitionToFailingItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url)
        ])
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .resourceLoading(.init()))],
                [.init(kind: .assetLoading(.init())), .init(kind: .failure(error: MockedError(), level: .fatal))]
            ],
            from: player.metricEventsPublisher
        ) {
            player.play()
        }
    }

    func testInitialDelivery() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.playbackState).toEventually(equal(.paused))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))]
            ],
            from: player.metricEventsPublisher
        )
    }
}
