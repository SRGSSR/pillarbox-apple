//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import Streams
import XCTest

final class ItemsUpdateTests: TestCase {
    func testUpdateWithCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem.simple(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3])
        player.items = [item4, item3, item1]
        expect(player.items).to(equalDiff([item4, item3, item1]))
        expect(player.currentIndex).to(equal(2))
    }

    func testUpdateWithCurrentItemMustNotInterruptPlayback() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem.simple(url: Stream.item(numbered: 4).url)
        let player = Player(items: [item1, item2, item3])
        expectNothingPublishedNext(from: player.queuePlayer.publisher(for: \.currentItem), during: .seconds(2)) {
            player.items = [item4, item3, item1]
        }
    }

    func testUpdateWithoutCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let item4 = PlayerItem.simple(url: Stream.item(numbered: 4).url)
        let item5 = PlayerItem.simple(url: Stream.item(numbered: 5).url)
        let item6 = PlayerItem.simple(url: Stream.item(numbered: 6).url)
        let player = Player(items: [item1, item2, item3])
        player.items = [item4, item5, item6]
        expect(player.items).to(equalDiff([item4, item5, item6]))
        expect(player.currentIndex).to(equal(0))
    }
}
