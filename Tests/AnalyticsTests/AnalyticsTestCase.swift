//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import Nimble
import XCTest

final class AnalyticsTestsCase: TestCase {
    func testEmptyPageViewTitle() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.trackPageView(title: " ")).to(throwAssertion())
    }

    func testEmptyEventTitle() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.sendEvent(name: " ")).to(throwAssertion())
    }
}
