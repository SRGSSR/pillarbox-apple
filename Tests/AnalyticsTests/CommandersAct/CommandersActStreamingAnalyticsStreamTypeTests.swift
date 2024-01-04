//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Foundation
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsStreamTypeTests: CommandersActTestCase {
    func testNoHearbeatsForUnknownStreamType() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(.play)
        expectNoHits(during: .milliseconds(200))
    }

    func testHearbeatsWhenStreamTypeIsFirstUpdatedDuringPlayback() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 1, uptimeInterval: 2)
        analytics.notify(.play)
        analytics.notify(streamType: .onDemand)
        expectAtLeastHits(.pos(), .pos())
    }

    func testHeartbeatsWhenStreamTypeChangesDuringPlayback() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 1, uptimeInterval: 2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        analytics.notify(streamType: .live)
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
}
