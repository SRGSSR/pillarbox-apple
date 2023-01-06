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

final class RawPlayerTests: XCTestCase {
    func testReplaceItemsWithEmpty() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = RawPlayer(items: [item1, item2, item3])

        player.replaceItems(with: [])

        expect(player.items()).to(beEmpty())
    }

    func testReplaceItemsWhenEmpty() {
        let player = RawPlayer()

        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        player.replaceItems(with: [item1, item2, item3])

        expect(player.items()).to(equalDiff([item1]))
        expect(player.items()).toEventually(equalDiff([item1, item2, item3]), timeout: .seconds(2))
    }

    func testReplaceItemsWithOtherItems() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = RawPlayer(items: [item1, item2, item3])

        let item4 = AVPlayerItem(url: Stream.item(numbered: 4).url)
        let item5 = AVPlayerItem(url: Stream.item(numbered: 5).url)
        player.replaceItems(with: [item4, item5])

        expect(player.items()).to(equalDiff([item4]))
        expect(player.items()).toEventually(equalDiff([item4, item5]), timeout: .seconds(2))
    }

    func testReplaceItemsWithPreservedCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = RawPlayer(items: [item1, item2, item3])

        let item4 = AVPlayerItem(url: Stream.item(numbered: 4).url)
        player.replaceItems(with: [item1, item4])

        expect(player.items()).to(equalDiff([item1]))
        expect(player.items()).toEventually(equalDiff([item1, item4]), timeout: .seconds(2))
    }

    func testReplaceItemsWithIdenticalItems() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = RawPlayer(items: [item1, item2])

        player.replaceItems(with: [item1, item2])

        expect(player.items()).to(equalDiff([item1, item2]))
    }

    func testReplaceItemsWithNextItems() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = RawPlayer(items: [item1, item2, item3])

        player.replaceItems(with: [item2, item3])

        expect(player.items()).to(equalDiff([item2]))
        expect(player.items()).toEventually(equalDiff([item2, item3]), timeout: .seconds(2))
    }

    func testReplaceItemsWithPreviousItems() {
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = RawPlayer(items: [item2, item3])

        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        player.replaceItems(with: [item1, item2, item3])

        expect(player.items()).to(equalDiff([item1]))
        expect(player.items()).toEventually(equalDiff([item1, item2, item3]), timeout: .seconds(2))
    }

    func testReplaceItemsLastReplacementWins() {
        let player = RawPlayer()

        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)

        player.replaceItems(with: [item1, item2])
        player.replaceItems(with: [item1])

        expect(player.items()).to(equalDiff([item1]))
        expect(player.items()).toNever(equalDiff([item1, item2]), until: .seconds(2))
    }
}
