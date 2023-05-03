//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsStateTransitionTests: CommandersActTestCase {
    func testLifeCycle() {
        expectAtLeastEvents(.play(), .stop()) {
           _ = CommandersActStreamingAnalytics()
        }
    }

    func testPlayPlay() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play, at: .zero)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPlayPause() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.pause()) {
            analytics.notify(.pause, at: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPlaySeek() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.seek()) {
            analytics.notify(.seek, at: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testPlayEof() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.eof()) {
            analytics.notify(.eof, at: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testPlayStop() {
        let analytics = CommandersActStreamingAnalytics()
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testPausePlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause, at: .zero)
        expectAtLeastEvents(.play()) {
            analytics.notify(.play, at: .zero)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPausePause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.pause, at: .zero)
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testSeekPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek, at: .zero)
        expectAtLeastEvents(.play()) {
            analytics.notify(.play, at: .zero)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testSeekPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.seek, at: .zero)
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testEofPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play, at: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.eof, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop, at: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testStopPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.stop, at: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop, at: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }
}
