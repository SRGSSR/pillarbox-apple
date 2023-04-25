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
        guard nimbleThrowAssertionsEnabled() else { return }
        expect(Analytics.shared.sendPageView(title: " ")).to(throwAssertion())
    }

    func testEmptyEventTitle() {
        guard nimbleThrowAssertionsEnabled() else { return }
        expect(Analytics.shared.sendEvent(name: " ")).to(throwAssertion())
    }
}
