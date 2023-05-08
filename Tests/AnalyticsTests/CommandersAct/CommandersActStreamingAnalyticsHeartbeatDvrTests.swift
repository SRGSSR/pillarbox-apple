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
    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeatInterval: .test) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        _ = analytics

        expectAtLeastEvents(
            .pos { labels in
                expect(labels.media_position).to(equal(1))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(1))
            },
            .pos { labels in
                expect(labels.media_position).to(equal(2))
            },
            .uptime { labels in
                expect(labels.media_position).to(equal(2))
            }
        )
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeatInterval: .test) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.pause)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeatInterval: .test) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.seek)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeatInterval: .test) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeatInterval: .test) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr, heartbeatInterval: .test) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(isBuffering: true)

        expectAtLeastEvents(
            .pos { labels in
                expect(labels.media_position).to(equal(0))
            },
            .uptime { labels in
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
