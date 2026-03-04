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

final class CommandersActSourceTests: CommandersActTestCase {
    func testLabels() {
        let source = CommandersActSource(
            page: .init(identifier: "page", version: "p", position: 3),
            section: .init(identifier: "section", version: "s", position: 4),
            labels: [
                "custom-label": "value"
            ]
        )
        expect(source.labels).to(equal([
            "page_id": "page",
            "page_version": "p",
            "section_position_in_page": "3",
            "section_id": "section",
            "section_version": "s",
            "item_position_in_section": "4",
            "custom-label": "value"
        ]))
    }

    func testCustomLabelsForbiddenOverrides() {
        let source = CommandersActSource(
            page: .init(identifier: "page", version: "p", position: 3),
            section: .init(identifier: "section", version: "s", position: 4),
            labels: [
                "page_id": "page42",
                "page_version": "p42",
                "section_position_in_page": "42",
                "section_id": "section42",
                "section_version": "s42",
                "item_position_in_section": "42"
            ]
        )
        expect(source.labels).to(equal([
            "page_id": "page",
            "page_version": "p",
            "section_position_in_page": "3",
            "section_id": "section",
            "section_version": "s",
            "item_position_in_section": "4"
        ]))
    }
}
