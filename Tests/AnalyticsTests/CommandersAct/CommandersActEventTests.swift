//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import Nimble
import XCTest

final class CommandersActEventTests: CommandersActTestCase {
    func testBlankName() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.sendEvent(commandersAct: .init(name: " "))).to(throwAssertion())
    }

    func testName() {
        expectAtLeastHits(.custom(name: "name")) {
            Analytics.shared.sendEvent(commandersAct: .init(name: "name"))
        }
    }

    func testCustomLabels() {
        expectAtLeastHits(
            .custom(name: "name") { labels in
                // Use `media_player_display`, a media-only key, so that its value can be parsed.
                expect(labels.media_player_display).to(equal("value"))
            }
        ) {
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "name",
                labels: ["media_player_display": "value"]
            ))
        }
    }

    func testCustomLabelsForbiddenOverrides() {
        expectAtLeastHits(.custom(name: "name")) {
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "name",
                labels: ["event_name": "overridden_name"]
            ))
        }
    }
}
