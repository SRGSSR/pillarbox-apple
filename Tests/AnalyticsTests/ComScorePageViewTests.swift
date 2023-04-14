//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import XCTest

final class ComScorePageViewTests: XCTestCase {
    func testLabels() {
        wait {
            Analytics.shared.sendPageView(title: "title")
        } received: { labels in
            expect(labels["c2"]).to(equal("6036016"))
            expect(labels["ns_ap_an"]).to(equal("xctest"))
            expect(labels["ns_category"]).to(equal("title"))
            expect(labels["ns_st_mp"]).to(beNil())
            expect(labels["mp_brand"]).to(equal("RTS"))
            expect(labels["mp_v"]).notTo(beNil())
        }
    }
}
