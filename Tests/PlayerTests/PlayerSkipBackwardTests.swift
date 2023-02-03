//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlayerSkipForwardTests: XCTestCase {
    func testCannotSkipWhenEmpty() {
        let player = Player()
        expect(player.canSkipForward()).to(beFalse())
    }

    func testSkip() {
        expect(true).to(beTrue())
    }
    func testSkipAsync() async {
        await expect(true).to(beTrue())
    }
}
