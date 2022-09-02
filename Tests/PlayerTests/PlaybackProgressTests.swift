//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlaybackProgressTests: XCTestCase {
    func testNil() {
        let progress = PlaybackProgress(value: nil, isInteracting: false)
        expect(progress.value).to(beNil())
        expect(progress.bounds).to(beNil())
    }

    func testValidValue() {
        let progress = PlaybackProgress(value: 0.5, isInteracting: false)
        expect(progress.value).to(equal(0.5))
        expect(progress.bounds).to(equal(0...1))
    }

    func testValuesOutsideBounds() {
        expect(PlaybackProgress(value: -100, isInteracting: false).value).to(equal(0))
        expect(PlaybackProgress(value: 100, isInteracting: false).value).to(equal(1))
    }
}
