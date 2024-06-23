//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ItemMoveAfterTests: TestCase {
    @MainActor
    func testMovePreviousItemAfterNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item1, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item3, item1]))
    }

    @MainActor
    func testMovePreviousItemAfterCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item1, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item3, item1]))
    }

    @MainActor
    func testMovePreviousItemAfterPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    @MainActor
    func testMoveCurrentItemAfterNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.currentIndex).to(equal(1))
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    @MainActor
    func testMoveCurrentItemAfterPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.currentIndex).to(equal(1))
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    @MainActor
    func testMoveNextItemAfterPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    @MainActor
    func testMoveNextItemAfterCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    @MainActor
    func testMoveNextItemAfterNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item2, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    @MainActor
    func testMoveItemAfterIdenticalItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.move(item, after: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    @MainActor
    func testMoveItemAfterItemAlreadyAtExpectedLocation() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.move(item2, after: item1)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    @MainActor
    func testMoveForeignItemAfterItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let foreignItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.move(foreignItem, after: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    @MainActor
    func testMoveItemAfterForeignItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let foreignItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.move(item, after: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    @MainActor
    func testMoveItemAfterLastItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }

    @MainActor
    func testMoveItemAfterNil() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.move(item1, after: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }

    @MainActor
    func testMoveLastItemAfterNil() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.move(item, after: nil)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }
}
