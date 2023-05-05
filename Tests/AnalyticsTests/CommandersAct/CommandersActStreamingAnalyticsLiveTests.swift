//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import CoreMedia
import Nimble

final class CommandersActStreamingAnalyticsLiveTests: CommandersActTestCase {
    private static let range = CMTimeRange(start: CMTime(value: 2, timescale: 1), duration: .zero)

    func testInitialPosition() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .live) {
                .init(labels: [:], time: CMTime(value: 18, timescale: 1), range: Self.range)
            }
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .live) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }
        wait(for: .seconds(3))
        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics.update = {
                .init(labels: [:], time: CMTime(value: 18, timescale: 1), range: Self.range)
            }
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }
        _ = analytics       // Silences the "was written to, but never read" warning.
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }

        analytics?.update = {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }
        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedWhenBufferingStarts() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }

        wait(for: .seconds(1))

        analytics?.update = {
            .init(labels: [:], time: CMTime(value: 16, timescale: 1), range: CMTimeRange(start: CMTime(value: 3, timescale: 1), duration: .zero))
        }

        analytics?.notify(isBuffering: true)

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) {
            .init(labels: [:], time: CMTime(value: 15, timescale: 1), range: Self.range)
        }
        wait(for: .seconds(3))

        analytics?.update = {
            .init(labels: [:], time: CMTime(value: 18, timescale: 1), range: CMTimeRange(start: CMTime(value: 5, timescale: 1), duration: .zero))
        }
        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }
}
