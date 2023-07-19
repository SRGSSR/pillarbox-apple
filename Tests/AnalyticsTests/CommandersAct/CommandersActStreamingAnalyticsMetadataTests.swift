//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Foundation
import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsMetadataTests: CommandersActTestCase {
    func testPlay() {
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_title).to(equal("title"))
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .onDemand) {
                .init(labels: ["media_title": "title"], time: CMTime(value: 2, timescale: 1), range: .zero)
            }
        }
    }

    func testStopWhenDestroyed() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) {
            .init(labels: ["media_title": "title"], time: .zero, range: .zero)
        }
        _ = analytics
        wait(for: .seconds(1))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_title).to(equal("title"))
            }
        ) {
            analytics = nil
        }
    }
}
