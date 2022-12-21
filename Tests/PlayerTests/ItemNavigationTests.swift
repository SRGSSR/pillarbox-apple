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
    
    func testCanGoBackToNextItemFailed() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3, item4])
        expect(player.canGoBackToPreviousItem()).to(beFalse())
    }
    
    func testCanGoBackToNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3, item4])
        player.advanceToNextItem()
        expect(player.canGoBackToPreviousItem()).to(beTrue())
    }
    
    func testGoBackToNextItemFailed() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3, item4])
        expect(player.goBackToPreviousItem()).to(beFalse())
    }
    
    func testGoBackToNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3, item4])
        
        (0..<3).forEach { _ in player.advanceToNextItem() }
        
        if case let .simple(url) = player.currentItem?.source.asset.type {
            expect(url).toAlways(equal(Stream.item(numbered: 4).url))
        } else { fail() }
        expect(player.goBackToPreviousItem()).to(beTrue())
        if case let .simple(url) = player.currentItem?.source.asset.type {
            expect(url).toAlways(equal(Stream.item(numbered: 3).url))
        } else { fail() }
        expect(player.goBackToPreviousItem()).to(beTrue())
        expect(player.goBackToPreviousItem()).to(beTrue())
        expect(player.goBackToPreviousItem()).to(beFalse())
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
