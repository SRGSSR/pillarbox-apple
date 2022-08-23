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
final class ItemTests: XCTestCase {
    func testEmptyItems() {
        let player = Player()
        expect(player.items).to(equal([]))
    }

    func testNonEmptyItems() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        expect(player.items).to(equal([item1, item2]))
    }

    func testSingleItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(item: item)
        expect(player.items).to(equal([item]))
    }

    func testInsertion() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])

        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item3, after: item1)
        expect(player.items).to(equal([item1, item3, item2]))
    }

    func testInsertionAfterNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])

        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item3, after: nil)
        expect(player.items).to(equal([item1, item2, item3]))
    }

    func testAppend() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])

        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.append(item3)
        expect(player.items).to(equal([item1, item2, item3]))
    }

    func testRemoval() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(item: item)
        player.remove(item)
        expect(player.items).to(equal([]))
    }

    func testUnknownItemRemoval() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(item: item)

        let unknownItem = AVPlayerItem(url: URL(string: "https://www.server.com/unknown.m3u8")!)
        player.remove(unknownItem)
        expect(player.items).to(equal([item]))
    }

    func testRemovalWhenEmpty() {
        let player = Player()
        let unknownItem = AVPlayerItem(url: URL(string: "https://www.server.com/unknown.m3u8")!)
        player.remove(unknownItem)
        expect(player.items).to(equal([]))
    }

    func testRemoveAll() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        player.removeAllItems()
        expect(player.items).to(equal([]))
    }
}
