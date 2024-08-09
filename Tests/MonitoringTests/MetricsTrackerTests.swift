//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

import PillarboxCircumspect
import PillarboxPlayer
import PillarboxStreams
import XCTest

final class MetricsTrackerTests: MonitoringTestCase {
    func testStart() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .init(serviceUrl: URL(string: "https://localhost")!)) {
                    .init(id: "id", metadataUrl: nil, assetUrl: nil)
                }
            ]
        ))

        expectAtLeastHits(
            start()
        ) {
            player.play()
        }
    }
}
