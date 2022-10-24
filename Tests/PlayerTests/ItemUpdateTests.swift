//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

@MainActor
final class ItemUpdateTests: XCTestCase {
    func testUpdateWithCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3])
        player.items = [item4, item3, item1]
        expect(player.items).to(equalDiff([item4, item3, item1]))
        expect(player.currentItem).to(equal(item1))
    }

    func testUpdateWithoutCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem(url: Stream.item(numbered: 4).url)
        let item5 = PlayerItem(url: Stream.item(numbered: 5).url)
        let item6 = PlayerItem(url: Stream.item(numbered: 6).url)
        let player = Player(items: [item1, item2, item3])
        player.items = [item4, item5, item6]
        expect(player.items).to(equalDiff([item4, item5, item6]))
        expect(player.currentItem).to(equal(item4))
    }
}
