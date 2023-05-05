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
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .onDemand) {
                .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: .zero)
            }
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: .zero)
        }
        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) { .empty }
        _ = analytics       // Silences the "was written to, but never read" warning.
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) { .empty }

        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: .zero)
        }

        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterSeek() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .onDemand) {
            .init(labels: [:], time: CMTime(value: 2, timescale: 1), range: .zero)
        }

        analytics?.notify(.seek)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            analytics = nil
        }
    }
}
