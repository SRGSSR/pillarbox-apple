//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxCircumspect
import PillarboxStreams

private struct MockedError: Error {}

final class CurrentMetricEventsPublisherTests: TestCase {
    func testPlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))]
            ],
            from: player.currentMetricEventsPublisher
        )
    }

    func testAssetFailure() {
        let publisher = Fail<Asset<Void>, Error>(error: MockedError())
        let player = Player(item: .init(publisher: publisher))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .failure(error: MockedError(), level: .fatal))]
            ],
            from: player.currentMetricEventsPublisher
        )
    }

    func testPlaybackFailure() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectAtLeastSimilarPublished(
            values: [
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .assetLoading(.init())), .init(kind: .failure(error: MockedError(), level: .fatal))]
            ],
            from: player.currentMetricEventsPublisher
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
                [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))],
                [.init(kind: .assetLoading(.init()))],
                [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))]
            ],
            from: player.currentMetricEventsPublisher
        ) {
            player.play()
        }
    }

    func testPlaylistTransitionToFailingItem() {

    }

    func testAdvanceInPlaylist() {
    }
}
