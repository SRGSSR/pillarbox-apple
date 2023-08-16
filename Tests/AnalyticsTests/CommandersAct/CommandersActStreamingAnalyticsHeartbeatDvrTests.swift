//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Foundation
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsHeartbeatDvrTests: CommandersActTestCase {
    private static var heartbeats: [CommandersActStreamingAnalytics.Heartbeat] = [
        .pos(delay: 1, interval: 1),
        .uptime(delay: 1, interval: 2)
    ]

    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
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
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .init(start: .zero, duration: .init(value: 100, timescale: 1)))
        }
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
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeats: Self.heartbeats) {
            .init(labels: [:], time: .zero, range: .zero)
        }
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
