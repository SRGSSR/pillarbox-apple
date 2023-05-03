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
            _ = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        }
    }

    func testPlayPlay() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        expect(analytics.lastEvent).to(equal(.play))
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPlayPause() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.pause()) {
            analytics.notify(.pause, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPlaySeek() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.seek()) {
            analytics.notify(.seek, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testPlayEof() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.eof()) {
            analytics.notify(.eof, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testPlayStop() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testPausePlay() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.pause, at: .zero, in: .zero)
        expectAtLeastEvents(.play()) {
            analytics.notify(.play, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPausePause() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.pause, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseSeek() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.pause, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseEof() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.pause, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseStop() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.pause, at: .zero, in: .zero)
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testSeekPlay() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.seek, at: .zero, in: .zero)
        expectAtLeastEvents(.play()) {
            analytics.notify(.play, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testSeekPause() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.seek, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekSeek() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.seek, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekEof() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.seek, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekStop() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.seek, at: .zero, in: .zero)
        expectAtLeastEvents(.stop()) {
            analytics.notify(.stop, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testEofPlay() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.eof, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofPause() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.eof, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofSeek() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.eof, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofEof() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.eof, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofStop() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.eof, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testStopPlay() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.stop, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopPause() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.stop, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.pause, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopSeek() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.stop, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.seek, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopEof() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.stop, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.eof, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopStop() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: .zero, isLive: false)
        analytics.notify(.stop, at: .zero, in: .zero)
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.stop, at: .zero, in: .zero)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }
}
