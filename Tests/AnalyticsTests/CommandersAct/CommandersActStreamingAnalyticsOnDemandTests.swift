//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsOnDemandTests: CommandersActTestCase {
    func testLifeCycle() {
        expectAtLeastEvents(.play(), .stop()) {
           _ = CommandersActStreamingAnalytics()
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

    func testDoublePlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play)
        }
    }

    func testDoublePause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause)
        }
    }

    func testDoubleSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek)
        }
    }

    func testDoubleEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof)
        }
    }

    func testDoubleStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop)
        }
    }

    func testPausePlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause)
        expectAtLeastEvents(.play()) {
            analytics.notify(.play)
        }
    }

    func testPauseSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause)
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop)
        }
    }
}
