//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestBridge
import Nimble
import XCTest

final class CommandersActEventTests: CommandersActTestCase {
    func testLabels() {
        wait { test in
            test.sendEvent(
                name: "name",
                type: "type",
                value: "value",
                source: "source",
                extra1: "extra1",
                extra2: "extra2",
                extra3: "extra3",
                extra4: "extra4",
                extra5: "extra5"
            )
        } received: { labels in
            expect(labels["event_name"] as? String).to(equal("name"))
            expect(labels["event_type"] as? String).to(equal("type"))
            expect(labels["event_value"] as? String).to(equal("value"))
            expect(labels["event_source"] as? String).to(equal("source"))
            expect(labels["event_value_1"] as? String).to(equal("extra1"))
            expect(labels["event_value_2"] as? String).to(equal("extra2"))
            expect(labels["event_value_3"] as? String).to(equal("extra3"))
            expect(labels["event_value_4"] as? String).to(equal("extra4"))
            expect(labels["event_value_5"] as? String).to(equal("extra5"))
        }
    }
}
