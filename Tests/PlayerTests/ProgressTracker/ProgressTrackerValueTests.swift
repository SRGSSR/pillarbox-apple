//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class ProgressTrackerValueTests: TestCase {
    @MainActor
    func testProgressValueInRange() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(progressTracker.range).toEventuallyNot(equal(0...0))
        progressTracker.progress = 0.5
        expect(progressTracker.progress).to(beCloseTo(0.5, within: 0.1))
    }

    @MainActor
    func testProgressValueBelowZero() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(progressTracker.range).toEventuallyNot(equal(0...0))
        progressTracker.progress = -10
        expect(progressTracker.progress).to(beCloseTo(0, within: 0.1))
    }

    @MainActor
    func testProgressValueAboveOne() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(progressTracker.range).toEventuallyNot(equal(0...0))
        progressTracker.progress = 10
        expect(progressTracker.progress).to(beCloseTo(1, within: 0.1))
    }

    func testCannotChangeProgressWhenUnavailable() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let player = Player()
        progressTracker.player = player
        expect(progressTracker.isProgressAvailable).to(equal(false))
        expect(progressTracker.progress).to(beCloseTo(0, within: 0.1))
        progressTracker.progress = 0.5
        expect(progressTracker.progress).to(beCloseTo(0, within: 0.1))
    }
}
