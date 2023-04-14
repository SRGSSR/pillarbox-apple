//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import XCTest

final class CommandersActEventTests: CommandersActTestCase {
    func testLabels() {
        expectAtLeastEvents(
            [
                .hidden_event { labels in
                    expect(labels.event_title).to(equal("name"))
                    expect(labels.event_type).to(equal("type"))
                    expect(labels.event_value).to(equal("value"))
                    expect(labels.event_source).to(equal("source"))
                    expect(labels.event_value_1).to(equal("extra1"))
                    expect(labels.event_value_2).to(equal("extra2"))
                    expect(labels.event_value_3).to(equal("extra3"))
                    expect(labels.event_value_4).to(equal("extra4"))
                    expect(labels.event_value_5).to(equal("extra5"))
                }
            ]
        ) {
            Analytics.shared.sendEvent(
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
        }
    }
}
