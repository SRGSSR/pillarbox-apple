//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import AVFoundation
import Nimble
import XCTest

final class ItemsTests: XCTestCase {
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
}
