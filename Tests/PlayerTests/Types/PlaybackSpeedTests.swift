//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlaybackSpeedTests: TestCase {
    func testNoValueClampingToIndefiniteRange() {
        let speed = PlaybackSpeed(value: 2, range: nil)
        expect(speed.value).to(equal(2))
        expect(speed.range).to(beNil())
    }

    func testValueClampingToDefiniteRange() {
        let speed = PlaybackSpeed(value: 2, range: 1...1)
        expect(speed.value).to(equal(1))
        expect(speed.range).to(equal(1...1))
    }

    func testEffectivePropertiesWhenIndefinite() {
        let speed = PlaybackSpeed.indefinite
        expect(speed.effectiveValue).to(equal(1))
        expect(speed.effectiveRange).to(equal(1...1))
    }

    func testEffectivePropertiesWhenDefinite() {
        let speed = PlaybackSpeed(value: 2, range: 0...2)
        expect(speed.effectiveValue).to(equal(2))
        expect(speed.effectiveRange).to(equal(0...2))
    }
}
