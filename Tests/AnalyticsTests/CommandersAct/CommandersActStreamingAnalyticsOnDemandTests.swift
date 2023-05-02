//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsOnDemandTests: CommandersActTestCase {
    func testLifeCycle() {
        expectAtLeastEvents(.play(), .stop()) {
           _ = CommandersActStreamingAnalytics()
        }
    }

    func testDoublePlay() {
        let analytics = CommandersActStreamingAnalytics()
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play)
        }
    }

    func testPause() {
        let analytics = CommandersActStreamingAnalytics()
        expectAtLeastEvents(.pause()) {
            analytics.notify(.pause)
        }
    }

    func testSeek() {
        let analytics = CommandersActStreamingAnalytics()
        expectAtLeastEvents(.seek()) {
            analytics.notify(.seek)
        }
    }

    func testEof() {
        let analytics = CommandersActStreamingAnalytics()
        expectAtLeastEvents(.eof()) {
            analytics.notify(.eof)
        }
    }

    func testStop() {
        let analytics = CommandersActStreamingAnalytics()
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop)
        }
    }
}
