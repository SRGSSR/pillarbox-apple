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

        expectAtLeastEvents(.pos(), .pos()) {
            analytics.notify(.play)
        }
    }

    func testNoHeartbeatAfterPause() {
    }

    func testNoHeartbeatAfterSeek() {
    }

    func testNoHeartbeatAfterEof() {
    }

    func testNoHeartbeatAfterStop() {
    }

    func testNoHeartbeatWhileBuffering() {
    }
}
