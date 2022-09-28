//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

@MainActor
final class ItemMoveBeforeCheckTests: XCTestCase {
    func testCanMovePreviousItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item1, before: item3)).to(beTrue())
    }

    func testCanMovePreviousItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item1, before: item3)).to(beTrue())
    }

    func testCanMovePreviousItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item2, before: item1)).to(beTrue())
    }

    func testCanMoveCurrentItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item1, before: item3)).to(beTrue())
    }

    func testCanMoveCurrentItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item2, before: item1)).to(beTrue())
    }

    func testCanMoveNextItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item3, before: item1)).to(beTrue())
    }

    func testCanMoveNextItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item3, before: item2)).to(beTrue())
    }

    func testCanMoveNextItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item3, before: item2)).to(beTrue())
    }

    func testCannotMoveBeforeIdenticalItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.canMove(item, before: item)).to(beFalse())
    }

    func testCannotMoveBeforeItemIfAlreadyAtExpectedLocation() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canMove(item1, before: item2)).to(beFalse())
    }

    func testCannotMoveForeignItemBeforeItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.canMove(foreignItem, before: item)).to(beFalse())
    }

    func testCannotMoveItemBeforeForeignItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.canMove(item, before: foreignItem)).to(beFalse())
    }

    func testCanMoveBeforeFirstItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canMove(item2, before: item1)).to(beTrue())
    }

    func testCanMoveItemBeforeNil() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canMove(item2, before: nil)).to(beTrue())
    }

    func testCannotFirstItemBeforeNil() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.canMove(item, before: nil)).to(beFalse())
    }
}
