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
    func testPlayableItemResourceLoading() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectOnlySimilarPublished(
            values: [
                .init(kind: .anyResourceLoading)
            ],
            from: item.resourceLoadingMetricEventPublisher()
        )
    }

    func testFailingItemResourceLoading() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.resourceLoadingMetricEventPublisher(), during: .milliseconds(500))
    }
}
