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
    private static let range = CMTimeRange(start: CMTime(value: 2, timescale: 1), end: CMTime(value: 20, timescale: 1))

    func testInitialPosition() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(5))
            }
        ) {
            _ = CommandersActStreamingAnalytics(
                at: CMTime(value: 15, timescale: 1),
                in: Self.range,
                isLive: true
            )
        }
    }
}
