//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class ResumeTests: TestCase {
    @MainActor
    func testResumeInFirstItemAtCreationTime() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item)
        await expect(player.time()).toEventually(equal(time))
    }

    @MainActor
    func testResumeInSecondItemAtCreationTime() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item2)
        expect(player.currentItem).to(equal(item2))
        await expect(player.time()).toEventually(equal(time))
    }

    @MainActor
    func testResumeInCurrentItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        await expect(player.playbackState).toEventually(equal(.paused))
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item)
        await expect(player.time()).toEventually(equal(time))
    }

    @MainActor
    func testResumeInNonCurrentItem() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.playbackState).toEventually(equal(.paused))
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item2)
        expect(player.currentItem).to(equal(item2))
        await expect(player.time()).toEventually(equal(time))
    }

    @MainActor
    func testResumeInUnknownItem() async {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let unknownItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        await expect(player.playbackState).toEventually(equal(.paused))
        player.resume(at(.init(value: 11, timescale: 1)), in: unknownItem)
        expect(player.currentItem).to(equal(item))
        expect(player.time()).to(equal(.zero))
    }

    @MainActor
    func testResumeIsAppliedOnce() async {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item1)
        await expect(player.time()).toEventually(equal(time))
        player.currentItem = item2
        player.currentItem = item1
        await expect(player.time()).toEventually(equal(.zero))
    }
}
