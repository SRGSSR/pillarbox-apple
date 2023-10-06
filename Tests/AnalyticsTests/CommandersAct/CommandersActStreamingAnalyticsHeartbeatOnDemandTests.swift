//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsHeartbeatOnDemandTests: CommandersActTestCase {
    private static var heartbeats: [CommandersActStreamingAnalytics.Heartbeat] = [
        .pos(delay: 1, interval: 1),
        .uptime(delay: 1, interval: 2)
    ]

    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        _ = analytics

        expectAtLeastHits(.pos(), .pos())
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(isBuffering: true)
        expectAtLeastHits(.pos(), .pos())
    }
}
