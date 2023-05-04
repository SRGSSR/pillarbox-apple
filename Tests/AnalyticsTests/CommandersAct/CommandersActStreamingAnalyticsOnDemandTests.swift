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
    private static let range = CMTimeRange(start: .zero, end: CMTime(value: 20, timescale: 1))

    func testInitialPosition() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            _ = CommandersActStreamingAnalytics(
                at: CMTime(value: 2, timescale: 1),
                in: Self.range,
                streamType: .onDemand
            )
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics(at: .zero, in: Self.range, streamType: .onDemand)
        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            analytics.notify(.pause, at: CMTime(value: 2, timescale: 1), in: Self.range)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(at: .zero, in: Self.range, streamType: .onDemand)
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

    func testPositionWhenDestroyedAfterPlayWhileBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init(at: .zero, in: Self.range, streamType: .onDemand)

        analytics?.notify(isBuffering: true, time: .zero, range: Self.range)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPlayWhileBuffering2() {
        var analytics: CommandersActStreamingAnalytics? = .init(at: .zero, in: Self.range, streamType: .onDemand)

        wait(for: .seconds(1))
        analytics?.notify(isBuffering: true, time: CMTime(value: 1, timescale: 1), range: Self.range)

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init(at: .zero, in: Self.range, streamType: .onDemand)
        analytics?.notify(.pause, at: CMTime(value: 2, timescale: 1), in: Self.range)
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
        var analytics: CommandersActStreamingAnalytics? = .init(at: .zero, in: Self.range, streamType: .onDemand)
        analytics?.notify(.seek, at: CMTime(value: 2, timescale: 1), in: Self.range)
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
            _ = CommandersActStreamingAnalytics(at: .zero, in: Self.range, streamType: .onDemand)
        }
    }
}
