//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class RepeatModeTests: TestCase {
    @MainActor
    func testRepeatOne() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.repeatMode = .one
        player.play()
        await expect(player.currentItem).toAlways(equal(item1), until: .seconds(2))
        player.repeatMode = .off
        await expect(player.currentItem).toEventually(equal(item2))
    }

    @MainActor
    func testRepeatAll() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        player.repeatMode = .all
        player.play()
        await expect(player.currentItem).toEventually(equal(item1))
        await expect(player.currentItem).toEventually(equal(item2))
        await expect(player.currentItem).toEventually(equal(item1))
        player.repeatMode = .off
        await expect(player.currentItem).toEventually(equal(item2))
        await expect(player.currentItem).toEventually(beNil())
    }

    @MainActor
    func testRepeatModeUpdateDoesNotRestartPlayback() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.play()
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.repeatMode = .one
        await expect(player.streamType).toNever(equal(.unknown), until: .milliseconds(100))
    }

    @MainActor
    func testRepeatModeUpdateDoesNotReplay() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        await expect(player.currentItem).toEventually(beNil())
        player.repeatMode = .one
        await expect(player.currentItem).toAlways(beNil(), until: .milliseconds(100))
    }
}
