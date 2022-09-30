//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

@MainActor
final class ItemNavigationTests: XCTestCase {
    func testCanReturnToPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.canReturnToPreviousItem()).to(beTrue())
    }

    func testCannotReturnToPreviousItemAtFront() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testCannotReturnToPreviousItemWhenEmpty() {
        let player = Player()
        expect(player.canReturnToPreviousItem()).to(beFalse())
    }

    func testReturnToPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.returnToPreviousItem()).to(beTrue())
        expect(player.currentItem).to(equal(item1))
    }

    func testReturnToPreviousItemAtFront() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.returnToPreviousItem()).to(beFalse())
        expect(player.currentItem).to(equal(item1))
    }

    func testCanAdvanceToNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canAdvanceToNextItem()).to(beTrue())
    }

    func testCannotAdvanceToNextItemAtBack() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testCannotAdvanceToNextItemWhenEmpty() {
        let player = Player()
        expect(player.canAdvanceToNextItem()).to(beFalse())
    }

    func testAdvanceToNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).to(equal(item2))
    }

    func testAdvanceToNextItemAtEnd() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.advanceToNextItem()).to(beFalse())
        expect(player.currentItem).to(equal(item2))
    }

    func testItemsOnFirstItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.items).to(equalDiff([item1, item2, item3]))
        expect(player.previousItems).to(beEmpty())
        expect(player.nextItems).to(equalDiff([item2, item3]))
    }

    func testItemsOnMiddleItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, item3]))
        expect(player.previousItems).to(equalDiff([item1]))
        expect(player.nextItems).to(equalDiff([item3]))
    }

    func testItemsOnLastItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, item3]))
        expect(player.previousItems).to(equalDiff([item1, item2]))
        expect(player.nextItems).to(beEmpty())
    }
}
