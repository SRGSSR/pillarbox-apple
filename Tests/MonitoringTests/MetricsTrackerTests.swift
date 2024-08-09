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
    func testEntirePlayback() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .init(serviceUrl: URL(string: "https://localhost")!)) { _ in .test }
            ]
        ))
        expectAtLeastHits(start(), stop()) {
            player.play()
        }
    }

    func testError() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .init(serviceUrl: URL(string: "https://localhost")!)) { _ in .test }
            ]
        ))
        expectAtLeastHits(start(), error()) {
            player.play()
        }
    }

    func testNoStopWithoutStart() {
        var player: Player? = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .init(serviceUrl: URL(string: "https://localhost")!)) { _ in .test }
            ]
        ))
        _ = player
        expectNoHits(during: .milliseconds(500)) {
            player = nil
        }
    }

    func testHeartbeats() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(
                    configuration: .init(
                        serviceUrl: URL(string: "https://localhost")!,
                        heartbeatInterval: 1
                    )
                ) { _ in .test }
            ]
        ))
        expectAtLeastHits(start(), heartbeat(), heartbeat()) {
            player.play()
        }
    }
}
