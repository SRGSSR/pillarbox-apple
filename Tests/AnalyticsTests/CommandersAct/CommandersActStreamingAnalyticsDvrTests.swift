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
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .dvr) {
                .init(labels: [:], time: CMTime(value: 18, timescale: 1), range: Self.range)
            }
        }
    }

    func testPositionAfterPause() {
        var time = CMTime(value: 15, timescale: 1)
        let analytics = CommandersActStreamingAnalytics(streamType: .dvr) {
            .init(labels: [:], time: time, range: Self.range)
        }

        wait(for: .seconds(3))
        time = CMTime(value: 18, timescale: 1)

        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }
        _ = analytics
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPlayAtNonStandardPlaybackSpeed() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }
        analytics?.notifyPlaybackSpeed(2)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }

        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var time = CMTime(value: 15, timescale: 1)
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .dvr) {
            .init(labels: [:], time: time, range: Self.range)
        }

        wait(for: .seconds(3))
        time = CMTime(value: 18, timescale: 1)
        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            analytics = nil
        }
    }
}
