//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation
import Nimble

final class PlayerRestartChecksTests: TestCase {
    func testEmptyPlayer() {
        let player = Player()
        expect(player.canRestart()).to(beFalse())
    }

    func testWithOneGoodItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.canRestart()).to(beFalse())
    }
}
