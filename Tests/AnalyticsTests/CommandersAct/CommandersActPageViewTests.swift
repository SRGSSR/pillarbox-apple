//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import Nimble
import XCTest

final class CommandersActPageViewTests: CommandersActTestCase {
    func testLabels() {
        expectAtLeastHits(
            .page_view { labels in
                expect(labels.page_type).to(equal("type"))
                expect(labels.content_title).to(equal("name"))
                expect(labels.navigation_level_0).to(beNil())
                expect(labels.navigation_level_1).to(equal("level_1"))
                expect(labels.navigation_level_2).to(equal("level_2"))
                expect(labels.navigation_level_3).to(equal("level_3"))
                expect(labels.navigation_level_4).to(equal("level_4"))
                expect(labels.navigation_level_5).to(equal("level_5"))
                expect(labels.navigation_level_6).to(equal("level_6"))
                expect(labels.navigation_level_7).to(equal("level_7"))
                expect(labels.navigation_level_8).to(equal("level_8"))
                expect(labels.navigation_level_9).to(beNil())
                expect(["phone", "tablet", "tvbox", "phone"]).to(contain([labels.navigation_device]))
                expect(labels.app_library_version).to(equal(Analytics.version))
                expect(labels.navigation_app_site_name).to(equal("site"))
                expect(labels.navigation_property_type).to(equal("app"))
                expect(labels.navigation_bu_distributer).to(equal("SRG"))
            }
        ) {
            Analytics.shared.trackPageView(
                comScore: .init(name: "name"),
                commandersAct: .init(
                    name: "name",
                    type: "type",
                    levels: [
                        "level_1",
                        "level_2",
                        "level_3",
                        "level_4",
                        "level_5",
                        "level_6",
                        "level_7",
                        "level_8"
                    ]
                )
            )
        }
    }

    func testBlankTitle() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.trackPageView(
            comScore: .init(name: "name"),
            commandersAct: .init(name: " ", type: "type")
        )).to(throwAssertion())
    }

    func testBlankType() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.trackPageView(
            comScore: .init(name: "name"),
            commandersAct: .init(name: "name", type: " ")
        )).to(throwAssertion())
    }

    func testBlankLevels() {
        expectAtLeastHits(
            .page_view { labels in
                expect(labels.page_type).to(equal("type"))
                expect(labels.content_title).to(equal("name"))
                expect(labels.navigation_level_1).to(beNil())
                expect(labels.navigation_level_2).to(beNil())
                expect(labels.navigation_level_3).to(beNil())
                expect(labels.navigation_level_4).to(beNil())
                expect(labels.navigation_level_5).to(beNil())
                expect(labels.navigation_level_6).to(beNil())
                expect(labels.navigation_level_7).to(beNil())
                expect(labels.navigation_level_8).to(beNil())
            }
        ) {
            Analytics.shared.trackPageView(
                comScore: .init(name: "name"),
                commandersAct: .init(
                    name: "name",
                    type: "type",
                    levels: [
                        " ",
                        " ",
                        " ",
                        " ",
                        " ",
                        " ",
                        " ",
                        " "
                    ]
                )
            )
        }
    }

    func testCustomLabels() {
        expectAtLeastHits(
            .page_view { labels in
                // Use `media_player_display`, a media-only key, so that its value can be parsed.
                expect(labels.media_player_display).to(equal("value"))
            }
        ) {
            Analytics.shared.trackPageView(
                comScore: .init(name: "name"),
                commandersAct: .init(
                    name: "name",
                    type: "type",
                    labels: ["media_player_display": "value"]
                )
            )
        }
    }

    func testLabelsForbiddenOverrides() {
        expectAtLeastHits(
            .page_view { labels in
                expect(labels.content_title).to(equal("name"))
            }
        ) {
            Analytics.shared.trackPageView(
                comScore: .init(name: "name"),
                commandersAct: .init(
                    name: "name",
                    type: "type",
                    labels: ["content_title": "overridden_title"]
                )
            )
        }
    }
}
