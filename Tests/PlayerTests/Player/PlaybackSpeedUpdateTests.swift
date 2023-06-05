//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlaybackSpeedUpdateTests: TestCase {
    func testUpdateIndefiniteWithDesired() {
        let speed = PlaybackSpeed(value: 1, range: 1...1)
        let updatedSpeed = speed.updated(with: .value(2))
        expect(updatedSpeed.value).to(equal(2))
        expect(updatedSpeed.range).to(equal(1...1))
    }

    func testUpdateIndefiniteWithRestricted() {
        let speed = PlaybackSpeed(value: 1, range: 1...1)
        let updatedSpeed = speed.updated(with: .range(0...2))
        expect(updatedSpeed.value).to(equal(1))
        expect(updatedSpeed.range).to(equal(0...2))
    }

    func testUpdateWithIndefiniteRangeMustPreserveValue() {
        let speed = PlaybackSpeed(value: 2, range: 1...1)
        let updatedSpeed = speed.updated(with: .range(1...1))
        expect(updatedSpeed.value).to(equal(2))
        expect(updatedSpeed.range).to(equal(1...1))
    }
}
