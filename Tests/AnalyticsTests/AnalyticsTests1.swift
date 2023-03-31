//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestHelpers
import Nimble
import XCTest

final class AnalyticsTests1: XCTestCase {
    override func setUp() {
        print("--> instance setup 1")
    }

    func test11() {
        expectEqual(values: ["6036016"], for: "c2", during: .seconds(10)) { sut in
            sut.trackPageView(title: "title")
        }
        expectEqual(values: ["6036016"], for: "c2", during: .seconds(4)) { sut in
            sut.trackPageView(title: "title")
        }
    }

    func test12() {
        print("--> 12")
    }
}
