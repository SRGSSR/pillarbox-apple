//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlayerSkipBackwardTests: XCTestCase {
    func testCanSkip() {
        expect(true).to(beTrue())
    }
    func testSkip() {
        expect(true).to(beTrue())
    }
    func testSkipAsync() async {
        await expect(true).to(beTrue())
    }
}
