//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics
import CoreMedia
import Foundation
import Nimble

final class CommandersActHeartbeatOnDemandTests: CommandersActTestCase {
    func testHeartbeatPosAfterPlay() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: .zero)
        }

        expectAtLeastEvents(.pos(), .pos())
    }

    func testNoHeartbeatAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.pause)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatAfterSeek() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.seek)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatAfterEof() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.eof)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatAfterStop() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(.stop)
        expectNoEvents(during: .seconds(2))
    }

    func testNoHeartbeatWhileBuffering() {
        let analytics = CommandersActStreamingAnalytics(streamType: .onDemand) {
            .init(labels: [:], time: .zero, range: .zero)
        }
        analytics.notify(isBuffering: true)
        expectAtLeastEvents(.pos(), .pos())
    }
}
