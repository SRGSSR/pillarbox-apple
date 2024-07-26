//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxStreams

final class AVPlayerItemMetricEventPublisherTests: TestCase {
    func testPlayableItemResourceLoadingMetricEvent() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectOnlySimilarPublished(
            values: [
                .init(kind: .anyResourceLoading)
            ],
            from: item.resourceLoadingMetricEventPublisher()
        )
    }

    func testFailingItemResourceLoadingMetricEvent() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.resourceLoadingMetricEventPublisher(), during: .milliseconds(500))
    }

    func testPlayableItemFailureMetricEvent() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.failureMetricEventPublisher(), during: .milliseconds(500))
    }

    func testFailingItemFailureMetricEvent() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectOnlySimilarPublished(
            values: [
                .init(kind: .anyFailure)
            ],
            from: item.failureMetricEventPublisher()
        )
    }

    func testPlayableItemWarningMetricEvent() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.warningMetricEventPublisher(), during: .milliseconds(500))
    }
}
