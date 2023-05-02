//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

// swiftlint:disable:next type_name
final class CommandersActStreamingAnalyticsOnDemandTests: CommandersActTestCase {
    func testLifeCycle() {
        expectAtLeastEvents(.play(), .stop()) {
           _ = CommandersActStreamingAnalytics()
        }
    }

    func testDoublePlay() {
        let analytics = CommandersActStreamingAnalytics()
        expectNoEvents(during: .seconds(2)) {
            analytics.notify(.play)
        }
    }
}
