//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import PillarboxStreams

final class AVPlayerItemMetricEventPublisherTests: TestCase {
    func testPlayableItemAssetReadyMetricEvent() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectOnlySimilarPublished(
            values: [.anyAssetReady],
            from: item.assetReadyMetricEventPublisher()
        )
    }

    func testFailingItemAssetReadyMetricEvent() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.assetReadyMetricEventPublisher(), during: .milliseconds(500))
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
            values: [.anyFailure],
            from: item.failureMetricEventPublisher()
        )
    }

    func testPlayableItemWarningMetricEvent() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.warningMetricEventPublisher(), during: .milliseconds(500))
    }

    func testPlayableItemStallMetricEvent() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.stallEventPublisher(), during: .milliseconds(500))
    }
}
