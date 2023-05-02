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

    func testPlayPlay() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play)
        }
    }

    func testPlayPause() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.pause()) {
            analytics.notify(.pause)
        }
    }

    func testPlaySeek() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.seek()) {
            analytics.notify(.seek)
        }
    }

    func testPlayEof() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.eof()) {
            analytics.notify(.eof)
        }
    }

    func testPlayStop() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.stop()) {
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

    func testPausePause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause)
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

    func testSeekPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek)
        expectAtLeastEvents(.play()) {
            analytics.notify(.play)
        }
    }

    func testSeekPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek)
        }
    }

    func testSeekEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek)
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop)
        }
    }

    func testEofPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof)
        }
    }

    func testEofStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testStopPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop)
        }
    }
}
