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
    func testResumeInFirstItemAtCreationTime() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item)
        expect(player.time()).toEventually(equal(time))
    }

    func testResumeInSecondItemAtCreationTime() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item2)
        expect(player.currentItem).to(equal(item2))
        expect(player.time()).toEventually(equal(time))
    }

    func testResumeInCurrentItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.playbackState).toEventually(equal(.paused))
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item)
        expect(player.time()).toEventually(equal(time))
    }

    func testResumeInNonCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.playbackState).toEventually(equal(.paused))
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item2)
        expect(player.currentItem).to(equal(item2))
        expect(player.time()).toEventually(equal(time))
    }

    func testResumeAtInvalidTime() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.playbackState).toEventually(equal(.paused))
        player.seek(at(.init(value: 11, timescale: 1)))
        expect(player.time()).toEventually(equal(CMTime(value: 11, timescale: 1)))
        player.resume(at(.invalid), in: item)
        expect(player.time()).toAlways(equal(CMTime(value: 11, timescale: 1)), until: .seconds(1))
    }

    func testResumeInUnknownItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let unknownItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.playbackState).toEventually(equal(.paused))
        player.resume(at(.init(value: 11, timescale: 1)), in: unknownItem)
        expect(player.currentItem).to(equal(item))
        expect(player.time()).to(equal(.zero))
    }

    func testResumeInPreviouslyLoadedItemAfterReplacement() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item1)
        expect(player.playbackState).toEventually(equal(.paused))

        player.items = [item2]
        expect(player.playbackState).toEventually(equal(.paused))

        let time = CMTime(value: 11, timescale: 1)
        player.items = [item1]
        player.resume(at(time), in: item1)
        expect(player.time()).toEventually(equal(time))
    }

    func testResumeIsAppliedOnce() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let time = CMTime(value: 11, timescale: 1)
        player.resume(at(time), in: item1)
        expect(player.time()).toEventually(equal(time))
        player.currentItem = item2
        player.currentItem = item1
        expect(player.time()).toEventually(equal(.zero))
    }
}
