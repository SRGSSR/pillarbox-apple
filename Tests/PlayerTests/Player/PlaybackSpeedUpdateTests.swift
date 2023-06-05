//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlaybackSpeedUpdateTests: TestCase {
    func testUpdateIndefiniteWithValue() {
        let speed = PlaybackSpeed.indefinite
        let updatedSpeed = speed.updated(with: .value(2))
        expect(updatedSpeed.value).to(equal(2))
        expect(updatedSpeed.range).to(beNil())
    }

    func testUpdateIndefiniteWithRange() {
        let speed = PlaybackSpeed.indefinite
        let updatedSpeed = speed.updated(with: .range(0...2))
        expect(updatedSpeed.value).to(equal(1))
        expect(updatedSpeed.range).to(equal(0...2))
    }

    func testUpdateDefiniteWithSameRange() {
        let speed = PlaybackSpeed(value: 2, range: 0...2)
        let updatedSpeed = speed.updated(with: .range(0...2))
        expect(updatedSpeed.value).to(equal(2))
        expect(updatedSpeed.range).to(equal(0...2))
    }

    func testUpdateDefiniteWithIndefiniteRange() {
        let speed = PlaybackSpeed(value: 2, range: 0...2)
        let updatedSpeed = speed.updated(with: .range(nil))
        expect(updatedSpeed.value).to(equal(1))
        expect(updatedSpeed.range).to(beNil())
    }
}
