//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ItemsUpdateTests: TestCase {
    func testUpdateWithCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let item4 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.items = [item4, item3, item1]
        expect(player.items).to(equal([item4, item3, item1]))
        expect(player.currentItem).to(equal(item1))
    }

    func testUpdateWithCurrentItemMustNotInterruptPlayback() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url)
        let item3 = PlayerItem.simple(url: Stream.onDemandWithSingleAudibleOption.url)
        let item4 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2, item3])
        expect(player.queuePlayer.currentItem?.url).toEventually(equal(Stream.onDemand.url))
        player.items = [item4, item3, item1]
        expect(player.queuePlayer.currentItem?.url).toAlways(equal(Stream.onDemand.url), until: .seconds(2))
    }

    func testUpdateWithoutCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let item4 = PlayerItem.simple(url: Stream.onDemand.url)
        let item5 = PlayerItem.simple(url: Stream.onDemand.url)
        let item6 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.items = [item4, item5, item6]
        expect(player.items).to(equal([item4, item5, item6]))
        expect(player.currentItem).to(equal(item4))
    }
}
