//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble
import PillarboxCircumspect
import TCServerSide
import XCTest

final class CommandersActEventTests: CommandersActTestCase {
    func testMergingWithGlobals() {
        let event = CommandersActEvent(
            name: "name",
            labels: [
                "event-label": "event",
                "common-label": "event"
            ]
        )
        let globals = CommandersActGlobals(
            consentServices: ["service1,service2,service3"],
            profileIdentifier: "profile",
            labels: [
                "globals-label": "globals",
                "common-label": "globals"
            ]
        )

        expect(event.merging(globals: globals).labels).to(equal([
            "consent_services": "service1,service2,service3",
            "profile_id": "profile",
            "globals-label": "globals",
            "event-label": "event",
            "common-label": "globals"
        ]))
    }

    func testLabels() {
        expectAtLeastHits(
            custom(name: "name") { labels in
                expect(labels.page_id).to(equal("page"))
            }
        ) {
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "name",
                source: .init(page: .init(identifier: "page"))
            ))
        }
    }

    func testBlankName() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
        expect(Analytics.shared.sendEvent(commandersAct: .init(name: " "))).to(throwAssertion())
    }

    func testName() {
        expectAtLeastHits(custom(name: "name")) {
            Analytics.shared.sendEvent(commandersAct: .init(name: "name"))
        }
    }

    func testCustomLabels() {
        expectAtLeastHits(
            custom(name: "name") { labels in
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

    func testUniqueIdentifier() {
        let identifier = TCPredefinedVariables.sharedInstance().uniqueIdentifier()
        expectAtLeastHits(
            custom(name: "name") { labels in
                expect(labels.context.device.sdk_id).to(equal(identifier))
                expect(labels.user.consistent_anonymous_id).to(equal(identifier))
            }
        ) {
            Analytics.shared.sendEvent(commandersAct: .init(name: "name"))
        }
    }

    func testGlobals() {
        expectAtLeastHits(
            custom(name: "name") { labels in
                expect(labels.consent_services).to(equal("service1,service2,service3"))
                expect(labels.profile_id).to(equal("profile"))
            }
        ) {
            Analytics.shared.sendEvent(commandersAct: .init(name: "name"))
        }
    }

    func testCustomLabelsForbiddenOverrides() {
        expectAtLeastHits(
            custom(name: "name") { labels in
                expect(labels.profile_id).to(equal("profile"))
                expect(labels.consent_services).to(equal("service1,service2,service3"))
                expect(labels.page_id).to(equal("page"))
            }
        ) {
            Analytics.shared.sendEvent(commandersAct: .init(
                name: "name",
                source: .init(page: .init(identifier: "page")),
                labels: [
                    "event_name": "overridden_name",
                    "profile_id": "profile42",
                    "consent_services": "service42",
                    "page_id": "page42"
                ]
            ))
        }
    }
}
