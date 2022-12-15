//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

@MainActor
final class ItemNavigationTests: XCTestCase {
    func testCanReturnToPreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnToPreviousItemAtFront() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCannotReturnToPreviousItemWhenEmpty() {
        let player = Player()
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCanAdvanceToNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    func testCannotAdvanceToNextItemAtBack() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testCannotAdvanceToNextItemWhenEmpty() {
        let player = Player()
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testCanAdvanceToNextItemOnFailedItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.unavailable.url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.canReturnToPreviousItem()).toAlways(beTrue(), until: .milliseconds(500))
    }

    func testCanReturnToPreviousItemOnFailedItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.unavailable.url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.canAdvanceToNextItem()).toAlways(beTrue(), until: .milliseconds(500))
    }

    func testAdvanceToNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).to(equal(item2))
    }

    func testAdvanceToNextItemAtBack() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.advanceToNextItem()).to(beFalse())
        expect(player.currentItem).to(equal(item2))
    }

    func testReturnToPreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.returnToPreviousItem()).to(beTrue())
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnToPreviousItemAtFront() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.returnToPreviousItem()).to(beFalse())
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnToPreviousItemOnFailedItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.unavailable.url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.returnToPreviousItem()).to(beTrue())
        expect(player.currentItem).to(equal(item1))
    }

    func testAdvanceToNextItemOnFailedItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.unavailable.url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).to(equal(item3))
    }
}
