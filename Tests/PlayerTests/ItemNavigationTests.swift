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

    func testCanReturnToPreviousFailingItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, failingItem, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).toEventually(equal(item2))
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnToPreviousFailingItemAtFront() {
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [failingItem, item])
        expect(player.currentItem).toEventually(equal(item))
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCannotReturnToPreviousItemWhenEmpty() {
        let player = Player()
        expect(player.canReturnToPreviousItem()).to(beFalse())
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

    func testReturnToPreviousFailingItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, failingItem, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).toEventually(equal(item2))
        expect(player.returnToPreviousItem()).to(beTrue())
        expect(player.currentItem).toEventually(equal(item1))
    }

    func testReturnToPreviousFailingItemAtFront() {
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [failingItem, item])
        expect(player.currentItem).toEventually(equal(item))
        expect(player.returnToPreviousItem()).to(beFalse())
        expect(player.currentItem).toEventually(equal(item))
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

    func testCanAdvanceToNextFailingItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, failingItem, item2])
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    func testCanAdvanceToNextFailingItemAtBack() {
        let item = PlayerItem(url: Stream.item.url)
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let player = Player(items: [item, failingItem])
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    func testCannotAdvanceToNextItemWhenEmpty() {
        let player = Player()
        expect(player.canAdvanceToNextItem()).to(beFalse())
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

    func testAdvanceToNextFailingItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, failingItem, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).toEventually(equal(item2))
    }

    func testAdvanceToNextFailingItemAtBack() {
        let item = PlayerItem(url: Stream.item.url)
        let failingItem = PlayerItem(url: Stream.unavailable.url)
        let player = Player(items: [item, failingItem])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).toEventually(equal(failingItem))
    }
}
