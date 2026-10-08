//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble

final class CommandersActSourceTests: CommandersActTestCase {
    func testLabelsMerging() {
        let source = CommandersActSource(
            page: .init(identifier: "page", version: "p", position: 3),
            section: .init(identifier: "section", version: "s", position: 4),
            labels: [
                "custom-label": "source",
                "page_id": "source"
            ]
        )
        expect(source.labels).to(equal([
            "page_id": "page",
            "page_version": "p",
            "section_position_in_page": "3",
            "section_id": "section",
            "section_version": "s",
            "item_position_in_section": "4",
            "custom-label": "source"
        ]))
    }
}
