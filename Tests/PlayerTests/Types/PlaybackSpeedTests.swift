//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlaybackSpeedTests: TestCase {
    func testDesired() {
        let playbackSpeed = PlaybackSpeed.desired(speed: 1)
        expect(playbackSpeed.value).to(equal(1))
        expect(playbackSpeed.range).to(equal(1...1))
        expect(playbackSpeed.input).to(equal(1))
    }

    func testDesiredOutOfBounds() {
        let playbackSpeed = PlaybackSpeed.desired(speed: 2)
        expect(playbackSpeed.value).to(equal(1))
        expect(playbackSpeed.range).to(equal(1...1))
        expect(playbackSpeed.input).to(equal(2))
    }

    func testActual() {
        let playbackSpeed = PlaybackSpeed.actual(speed: 1, in: 0...1)
        expect(playbackSpeed.value).to(equal(1))
        expect(playbackSpeed.range).to(equal(0...1))
        expect(playbackSpeed.input).to(equal(1))
    }

    func testActualOutOfBounds() {
        let playbackSpeed = PlaybackSpeed.actual(speed: 2, in: 0...1)
        expect(playbackSpeed.value).to(equal(1))
        expect(playbackSpeed.range).to(equal(0...1))
        expect(playbackSpeed.input).to(equal(2))
    }
}
