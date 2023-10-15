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
        expectAtLeastHits(.play(), .stop()) {
            _ = CommandersActStreamingAnalytics(streamType: .unknown)
        }
    }

    func testPlayPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        expect(analytics.lastEvent).to(equal(.play))
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPlayPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastHits(.pause()) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPlaySeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastHits(.seek()) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testPlayEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastHits(.eof()) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testPlayStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        expect(analytics.lastEvent).to(equal(.play))
        expectAtLeastHits(.stop()) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testPlayDeinit() {
        expectAtLeastHits(.play(), .stop()) {
            _ = CommandersActStreamingAnalytics(streamType: .unknown)
        }
    }

    func testPausePlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.pause)
        expectAtLeastHits(.play()) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testPausePause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.pause)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.pause))
        }
    }

    func testPauseStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.pause)
        expectAtLeastHits(.stop()) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testPauseDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics?.notify(.pause)
        expectAtLeastHits(.stop()) {
            analytics = nil
        }
    }

    func testSeekPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.seek)
        expectAtLeastHits(.play()) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.play))
        }
    }

    func testSeekPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.seek)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.seek))
        }
    }

    func testSeekStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.seek)
        expectAtLeastHits(.stop()) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testSeekDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics?.notify(.seek)
        expectAtLeastHits(.stop()) {
            analytics = nil
        }
    }

    func testEofPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.eof)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.eof))
        }
    }

    func testEofDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics?.notify(.eof)
        expectNoHits(during: .seconds(2)) {
            analytics = nil
        }
    }

    func testStopPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.play)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.pause)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.seek)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.eof)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics.notify(.stop)
        expectNoHits(during: .seconds(2)) {
            analytics.notify(.stop)
            expect(analytics.lastEvent).to(equal(.stop))
        }
    }

    func testStopDeinit() {
        var analytics: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics(streamType: .unknown)
        analytics?.notify(.stop)
        expectNoHits(during: .seconds(2)) {
            analytics = nil
        }
    }
}
