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
final class ItemMoveAfterTests: XCTestCase {
    func testMovePreviousItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        expect(player.move(item1, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item3, item1]))
        expect(player.nextItems).to(equalDiff([item3, item1]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMovePreviousItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        expect(player.move(item1, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item3, item1]))
        expect(player.nextItems).to(equalDiff([item1]))
        expect(player.previousItems).to(equalDiff([item2]))
    }

    func testMovePreviousItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item2, item1]))
    }

    func testMoveCurrentItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.currentItem).to(equal(item2))
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(equalDiff([item1, item3]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMoveCurrentItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.currentItem).to(beNil())
        expect(player.items).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1, item3, item2]))
    }

    func testMoveCurrentFirstItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.currentItem).to(equal(item2))
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(equalDiff([item1, item3]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMoveNextItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1, item3]))
    }

    func testMoveNextItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems).to(equalDiff([item3, item2]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMoveNextItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        expect(player.move(item2, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems).to(equalDiff([item3, item2]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMoveAfterIdenticalItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.move(item, after: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveAfterItemAlreadyAtExpectedLocation() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item2, after: item1)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testMoveAfterForeignItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.move(item, after: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveAfterNil() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item1, after: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }
}
