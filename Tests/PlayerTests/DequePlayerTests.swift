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
final class DequeuePlayerTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequeuePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testAdvanceToNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequeuePlayer(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equal([item1]))
    }

    func testReturnToPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequeuePlayer(items: [item1, item2])
        player.advanceToNextItem()
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testAdvanceAfterLastItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequeuePlayer(items: [item])
        player.advanceToNextItem()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(equal([item]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equal([item]))
    }

    func testReturnBeforeFirstItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequeuePlayer(items: [item])
        player.returnToPreviousItem()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(beNil())
        expect(player.nextItems()).to(equal([item]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertAfterItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequeuePlayer(items: [item1, item2])
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        player.insert(item3, after: item1)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, item3, item2]))
        expect(player.nextItems()).to(equal([item3, item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertBeforeItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequeuePlayer(items: [item1, item2])
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        player.insert(item3, before: item1)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item3, item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(equal([item3]))
    }

    func testInsertAfterNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = DequeuePlayer(items: [item1])
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item2, after: nil)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertBeforeNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = DequeuePlayer(items: [item1])
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item2, before: nil)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item2, item1]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equal([item2]))
    }
}
