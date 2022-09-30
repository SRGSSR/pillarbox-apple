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
final class ItemTests: XCTestCase {
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

    func testEmpty() {
        let player = Player()
        expect(player.currentItem).to(beNil())
        expect(player.items).to(beEmpty())
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(beEmpty())
    }
}
