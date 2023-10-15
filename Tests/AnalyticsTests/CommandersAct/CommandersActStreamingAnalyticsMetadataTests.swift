//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsMetadataTests: CommandersActTestCase {
    func testPlay() {
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_title).to(equal("name"))
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .onDemand)
        }
    }

    func testStopWhenDestroyed() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live)
        _ = analytics
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_title).to(equal("name"))
            }
        ) {
            analytics = nil
        }
    }
}
