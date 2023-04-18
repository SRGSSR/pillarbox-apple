//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import Streams
import XCTest

final class ItemNavigationBackwardChecksTests: TestCase {
    func testCanReturnToPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnToPreviousItemAtFront() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCannotReturnToPreviousItemWhenEmpty() {
        let player = Player()
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCanReturnToPreviousItemOnFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.canReturnToPreviousItem()).toAlways(beTrue(), until: .seconds(1))
    }
}
