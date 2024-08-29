//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class RepeatModeTests: TestCase {
    func testRepeatOne() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.repeatMode = .one
        player.play()
        expect(player.currentItem).toAlways(equal(item1), until: .seconds(2))
        player.repeatMode = .off
        expect(player.currentItem).toEventually(equal(item2))
    }

    func testRepeatAll() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        player.repeatMode = .all
        player.play()
        expect(player.currentItem).toEventually(equal(item1))
        expect(player.currentItem).toEventually(equal(item2))
        expect(player.currentItem).toEventually(equal(item1))
        player.repeatMode = .off
        expect(player.currentItem).toEventually(equal(item2))
        expect(player.currentItem).toEventually(beNil())
    }

    func testStreamTypeNotUpdated() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.play()
        expect(player.streamType).toEventually(equal(.onDemand))
        player.repeatMode = .one
        expect(player.streamType).toNever(equal(.unknown), until: .milliseconds(100))
    }
}
