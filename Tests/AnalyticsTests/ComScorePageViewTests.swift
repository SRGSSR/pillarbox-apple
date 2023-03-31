//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import XCTest

final class ComScorePageViewTests1: TestCase {
    func testPageView() {
        Analytics.shared.trackPageView(title: "title")
        let _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 10)
    }
}
