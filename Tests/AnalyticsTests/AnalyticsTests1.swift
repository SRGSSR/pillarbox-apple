//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import XCTest

final class AnalyticsTests1: TestCase {
    override func setUp() {
        print("--> instance setup 1")
    }

    func test11() {
        expect(events: ["6036016"]) {
            self.trackTestPageView(title: "title")
        }
    }

    func test12() {
        print("--> 12")
    }
}
