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
            _ = CommandersActStreamingAnalytics(streamType: .onDemand) {
                .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: Self.range)
            }
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: Self.range)
        }
        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            analytics.update = {
                .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: Self.range)
            }
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: Self.range)
        }
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
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: Self.range)
        }

        analytics?.update = {
            .init(labels: [:], time: .zero, range: Self.range)
        }
        analytics?.notify(isBuffering: true)
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
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: Self.range)
        }

        wait(for: .seconds(1))
        analytics?.update = {
            .init(labels: [:], time: CMTime(value: 1, timescale: 1), range: Self.range)
        }
        analytics?.notify(isBuffering: true)

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: Self.range)
        }
        analytics?.update = {
            .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: Self.range)
        }
        analytics?.notify(.pause)
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
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: Self.range)
        }
        analytics?.update = {
            .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: Self.range)
        }
        analytics?.notify(.seek)
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
            _ = CommandersActStreamingAnalytics(streamType: .onDemand) {
                .init(labels: [:], time: .zero, range: Self.range)
            }
        }
    }
}
