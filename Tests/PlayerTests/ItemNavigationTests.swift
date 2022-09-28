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
    func testReturnToPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).to(equal(item2))

        expect(player.returnToPreviousItem()).to(beTrue())
        expect(player.currentItem).to(equal(item1))
        expect(player.items).to(equalDiff([item1, item2]))
        expect(player.nextItems).to(equalDiff([item2]))
        expect(player.previousItems).to(beEmpty())
    }

    func testReturnToPreviousItemAtFront() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        expect(player.returnToPreviousItem()).to(beFalse())
        expect(player.currentItem).to(equal(item1))
        expect(player.items).to(equalDiff([item1, item2]))
        expect(player.nextItems).to(equalDiff([item2]))
        expect(player.previousItems).to(beEmpty())
    }

    func testAdvanceToNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).to(equal(item2))
        expect(player.items).to(equalDiff([item1, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1]))
    }

    func testAdvanceToNextItemAtEnd() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.advanceToNextItem()).to(beTrue())
        expect(player.currentItem).to(equal(item2))

        expect(player.advanceToNextItem()).to(beFalse())
        expect(player.currentItem).to(equal(item2))
        expect(player.items).to(equalDiff([item1, item2]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1]))
    }
}
