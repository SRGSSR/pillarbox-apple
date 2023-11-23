//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsHeartbeatLiveTests: CommandersActTestCase {
    private static let posInterval: TimeInterval = 1
    private static let uptimeInterval: TimeInterval = 2

    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        analytics.notify(.play)
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

    func testNoHeartbeatInitially() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        analytics.notify(.play)
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        analytics.notify(.play)
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(streamType: .live)
        analytics.notify(.play)
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
