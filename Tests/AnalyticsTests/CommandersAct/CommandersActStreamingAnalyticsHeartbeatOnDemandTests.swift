//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import CoreMedia

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsHeartbeatOnDemandTests: CommandersActTestCase {
    func testNoHeartbeatInitially() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        expectNoHits(during: .milliseconds(300))
    }

    func testHeartbeatAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        expectAtLeastHits(.pos(), .pos())
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        analytics.notify(.pause)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        analytics.notify(.seek)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(300))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(300))
    }

    func testHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(posInterval: 0.1, uptimeInterval: 0.2)
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        analytics.notify(isBuffering: true)
        expectAtLeastHits(.pos(), .pos())
    }
}
