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
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .dvr)
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr)
        wait(for: .seconds(3))

        expectAtLeastHits(
            .pause { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr)
        _ = analytics
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
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr)
        analytics?.notifyPlaybackSpeed(2)
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

    func testPositionWhenDestroyedAfterPlayAtSeveralNonStandardPlaybackSpeeds() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr)
        wait(for: .seconds(1))
        analytics?.notifyPlaybackSpeed(2)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr)
        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr)
        wait(for: .seconds(3))
        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            analytics = nil
        }
    }
}
