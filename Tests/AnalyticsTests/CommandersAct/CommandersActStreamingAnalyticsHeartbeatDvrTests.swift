//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsHeartbeatDvrTests: CommandersActTestCase {
    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 1, uptimeInterval: 2)
        analytics.notify(streamType: .dvr)
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

    func testHeartbeatAfterPlayInPastConditions() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 1, uptimeInterval: 2)
        analytics.notify(streamType: .dvr)
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
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .dvr)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .dvr)
        analytics.notify(.play)
        analytics.notify(.pause)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .dvr)
        analytics.notify(.play)
        analytics.notify(.seek)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .dvr)
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .dvr)
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(300))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .dvr)
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
