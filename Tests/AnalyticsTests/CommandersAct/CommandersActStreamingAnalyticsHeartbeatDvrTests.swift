//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsHeartbeatDvrTests: CommandersActTestCase {
    private static var heartbeats: [CommandersActStreamingAnalytics.Heartbeat] = [
        .pos(delay: 1, interval: 1),
        .uptime(delay: 1, interval: 2)
    ]

    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        _ = analytics
        expectAtLeastHits(
            .pos { labels in
                expect(labels.media_position).to(equal(1))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(1))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(2))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(3))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(3))
            }
        )
    }

    func testHeartbeatAfterPlayInPastConditions() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        _ = analytics
        expectAtLeastHits(
            .pos { labels in
                expect(labels.media_position).to(equal(1))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(1))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(2))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(3))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(3))
            }
        )
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats)
        analytics.notify(isBuffering: true)

        expectAtLeastHits(
            .pos { labels in
                expect(labels.media_position).to(equal(0))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(0))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(0))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(0))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(0))
            }
        )
    }
}
