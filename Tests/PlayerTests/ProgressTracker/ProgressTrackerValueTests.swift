//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import Streams
import XCTest

final class ProgressTrackerValueTests: TestCase {
    func testProgressValueInRange() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.range).toEventuallyNot(equal(0...0))
        progressTracker.progress = 0.5
        expect(progressTracker.progress).to(beCloseTo(0.5, within: 0.1))
    }

    func testProgressValueBelowZero() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.range).toEventuallyNot(equal(0...0))
        progressTracker.progress = -10
        expect(progressTracker.progress).to(beCloseTo(0, within: 0.1))
    }

    func testProgressValueAboveOne() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.range).toEventuallyNot(equal(0...0))
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
