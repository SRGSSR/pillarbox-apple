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

    func testResumeInCurrentItemDuringPlayback() {
    }

    func testResumeInNonCurrentItemDuringPlayback() {
    }

    func testResumeInUnknownItem() {
    }

    func testResumeIsAppliedOnce() {
    }

    func testResumeOverridesPlaybackConfiguration() {
    }

    func testResumeIsPreservedByCompatibleItemUpdate() {
    }

    func testResumeIsDiscardedByIncompatibleItemUpdate() {
    }
}
