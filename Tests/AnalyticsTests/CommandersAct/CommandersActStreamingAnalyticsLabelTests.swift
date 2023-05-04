//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsLabelTests: CommandersActTestCase {
    func testMediaPlayerProperties() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
            },
            .stop { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
            }
        ) {
            _ = CommandersActStreamingAnalytics(at: .zero, in: .zero, streamType: .unknown)
        }
    }
}
