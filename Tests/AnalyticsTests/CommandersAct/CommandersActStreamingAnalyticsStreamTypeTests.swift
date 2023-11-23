//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Foundation
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsStreamTypeTests: CommandersActTestCase {
    private static let posInterval: TimeInterval = 1
    private static let uptimeInterval: TimeInterval = 2

    func testNoHearbeatsForUnknownStreamType() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(.play)
        expectNoHits(during: .seconds(2))
    }

    func testHearbeatsWhenStreamTypeIsFirstUpdatedDuringPlayback() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
        analytics.notify(.play)
        analytics.notify(streamType: .onDemand)
        expectAtLeastHits(.pos(), .pos())
    }

    func testHeartbeatsWhenStreamTypeChangesDuringPlayback() {
        let analytics = CommandersActStreamingAnalytics(posInterval: Self.posInterval, uptimeInterval: Self.uptimeInterval)
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
