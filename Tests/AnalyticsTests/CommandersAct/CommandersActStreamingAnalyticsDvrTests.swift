//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import CoreMedia
import Nimble

final class CommandersActStreamingAnalyticsDvrTests: CommandersActTestCase {
    private static let range = CMTimeRange(start: CMTime(value: 2, timescale: 1), end: CMTime(value: 20, timescale: 1))

    func testInitialPosition() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(streamType: .dvr)
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            analytics.update(time: .init(value: 18, timescale: 1), range: Self.range)
            analytics.notify(.play)
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics()
        analytics.notify(streamType: .dvr)
        analytics.update(time: .init(value: 18, timescale: 1), range: Self.range)
        analytics.notify(.play)
        wait(for: .seconds(1))
        expectAtLeastHits(
            .pause { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .dvr)
        analytics?.update(time: .init(value: 15, timescale: 1), range: Self.range)
        analytics?.notify(.play)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPlayAtNonStandardPlaybackSpeed() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .dvr)
        analytics?.update(time: .init(value: 15, timescale: 1), range: Self.range)
        analytics?.notifyPlaybackSpeed(2)
        analytics?.notify(.play)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(3))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPlayAtSeveralNonStandardPlaybackSpeeds() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .dvr)
        analytics?.update(time: .init(value: 15, timescale: 1), range: Self.range)
        analytics?.notify(.play)
        wait(for: .seconds(1))
        analytics?.notifyPlaybackSpeed(2)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(equal(3))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .dvr)
        analytics?.update(time: .init(value: 15, timescale: 1), range: Self.range)
        analytics?.notify(.play)
        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(6))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init()
        analytics?.notify(streamType: .dvr)
        analytics?.update(time: .init(value: 15, timescale: 1), range: Self.range)
        analytics?.notify(.play)
        wait(for: .seconds(1))
        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(6))
            }
        ) {
            analytics = nil
        }
    }
}
