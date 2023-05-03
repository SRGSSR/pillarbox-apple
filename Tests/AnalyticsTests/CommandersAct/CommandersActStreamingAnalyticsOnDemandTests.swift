//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

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

    func testPositionWhenDestroyedWhilePlaying() {

    }

    func testPositionWhenDestroyedWhilePaused() {

    }

    func testPositionWhenDestroyedWhileSeeking() {

    }

    func testPositionWhenDestroyedWhileEnded() {

    }

    func testPositionWhenDestroyedWhileStopped() {

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
