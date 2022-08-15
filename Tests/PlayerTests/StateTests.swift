//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import Nimble
import XCTest

final class StateTests: XCTestCase {
    func testInitialState() {
        let player = Player()
        expect(player.state).to(equal(.idle))
    }
}
