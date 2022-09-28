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
final class ItemMoveBeforeTests: XCTestCase {
    func testMovePreviousItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item1, before: item3)
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(equalDiff([item1, item3]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMovePreviousItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item1, before: item3)
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item2, item1]))
    }

    func testMovePreviousItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item2, before: item1)
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item2, item1]))
    }

    func testMoveCurrentItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item1, before: item3)
        expect(player.currentItem).to(equal(item2))
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(equalDiff([item1, item3]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMoveCurrentItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item2, before: item1)
        expect(player.currentItem).to(equal(item3))
        expect(player.items).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item2, item1]))
    }

    func testMoveCurrentLastItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item3, before: item1)
        expect(player.currentItem).to(beNil())
        expect(player.items).to(equalDiff([item3, item1, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item3, item1, item2]))
    }

    func testMoveNextItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item3, before: item1)
        expect(player.items).to(equalDiff([item3, item1, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item3, item1]))
    }

    func testMoveNextItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item3, before: item2)
        expect(player.items).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1, item3]))
    }

    func testMoveNextItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item3, before: item2)
        expect(player.items).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems).to(equalDiff([item3, item2]))
        expect(player.previousItems).to(beEmpty())
    }

    func testMoveBeforeIdenticalItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(items: [item])
        player.move(item, before: item)
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveBeforeForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = Player(items: [item])
        player.move(item, before: foreignItem)
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveBeforeNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = Player(items: [item1, item2])
        player.move(item2, before: nil)
        expect(player.items).to(equalDiff([item2, item1]))
    }
}
