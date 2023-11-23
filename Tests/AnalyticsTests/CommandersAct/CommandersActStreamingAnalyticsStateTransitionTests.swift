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
        expectNoHits(during: .milliseconds(500)) {
            _ = CommandersActStreamingAnalytics()
        }
    }

    func testPlayPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPlayPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        expectAtLeastHits(.pause()) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPlaySeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        expectAtLeastHits(.seek()) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testPlayEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        expectAtLeastHits(.eof()) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testPlayStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        expectAtLeastHits(.stop()) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testPausePlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.pause)
        expectAtLeastHits(.play()) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPausePause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.pause)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.pause)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.pause)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.pause)
        expectAtLeastHits(.stop()) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testPauseDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics()
        analytics?.notify(.play)
        analytics?.notify(.pause)
        expectAtLeastHits(.stop()) {
            analytics = nil
        }
    }

    func testSeekPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.seek)
        expectAtLeastHits(.play()) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testSeekPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.seek)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.seek)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.seek)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.seek)
        expectAtLeastHits(.stop()) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testSeekDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics()
        analytics?.notify(.play)
        analytics?.notify(.seek)
        expectAtLeastHits(.stop()) {
            analytics = nil
        }
    }

    func testEofPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.eof)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics()
        analytics?.notify(.play)
        analytics?.notify(.eof)
        expectNoHits(during: .milliseconds(500)) {
            analytics = nil
        }
    }

    func testStopPlay() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopSeek() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopEof() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopStop() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(.play)
        analytics.notify(.stop)
        expectNoHits(during: .milliseconds(500)) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics()
        analytics?.notify(.play)
        analytics?.notify(.stop)
        expectNoHits(during: .milliseconds(500)) {
            analytics = nil
        }
    }
}
