//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import Nimble
import XCTest

final class CommandersActEventTests: CommandersActTestCase {
    func testBlankName() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.sendEvent(commandersAct: .init(name: " "))).to(throwAssertion())
    }

    func testName() {
        expectAtLeastHits(.custom(name: "name")) {
            Analytics.shared.sendEvent(commandersAct: .init(name: "name"))
        }
    }
}
