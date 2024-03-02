//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble
import PillarboxCircumspect

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsOnDemandTests: CommandersActTestCase {
    func testInitialPosition() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(streamType: .onDemand)
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics.notify(.play)
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(streamType: .onDemand)
        analytics.notify(.play)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .pause { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .onDemand)
        analytics?.notify(.play)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPlayAtNonStandardPlaybackSpeed() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .onDemand)
        analytics?.notify(.play)
        analytics?.notifyPlaybackSpeed(2)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPlayAtSeveralNonStandardPlaybackSpeeds() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .onDemand)
        analytics?.notify(.play)
        wait(for: .seconds(1))
        analytics?.notifyPlaybackSpeed(2)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .onDemand)
        analytics?.notify(.play)
        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .onDemand)
        analytics?.notify(.play)
        wait(for: .seconds(1))
        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterSeek() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .onDemand)
        analytics?.notify(.play)
        wait(for: .seconds(1))
        analytics?.notify(.seek)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }
}
