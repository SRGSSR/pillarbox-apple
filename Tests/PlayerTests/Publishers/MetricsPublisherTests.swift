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

final class MetricsPublisherTests: TestCase {
    func testCurrentMetricEventsPublisher() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastSimilarPublished(values: [
            [.init(kind: .assetLoading(.init()))],
            [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))]
        ], from: player.currentMetricEventsPublisher) {
            player.play()
        }
    }
}
