//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import CoreMedia
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsOnDemandTests: CommandersActTestCase {
    func testInitialPosition() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            _ = CommandersActStreamingAnalytics()
        }
    }

    func testIntermediatePosition() {
        let analytics = CommandersActStreamingAnalytics()
        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            analytics.notify(.pause, at: CMTime(value: 2, timescale: 1))
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        _ = analytics       // Silences the "was written to, but never read" warning.
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(.pause, at: CMTime(value: 2, timescale: 1))
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterSeek() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(.seek, at: CMTime(value: 2, timescale: 1))
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterEof() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(.eof, at: CMTime(value: 2, timescale: 1))
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            analytics = nil
        }
    }

    func testNoTimeshift() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            _ = CommandersActStreamingAnalytics()
        }
    }
}
