//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import Nimble
import XCTest

final class ItemsTests: XCTestCase {
    func testInitialItems() {
        let player = Player()
        expect(player.items).to(equal([]))
    }
}
