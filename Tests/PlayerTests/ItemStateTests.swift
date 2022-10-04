//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class ItemStateTests: XCTestCase {
    func testEquality() {
        expect(ItemState.unknown).to(equal(.unknown))
        expect(ItemState.readyToPlay).to(equal(.readyToPlay))
        expect(ItemState.ended).to(equal(.ended))
        expect(ItemState.failed(error: TestError.any)).to(equal(.failed(error: TestError.any)))
    }

    func testInequality() {
        expect(ItemState.unknown).notTo(equal(.readyToPlay))
        expect(ItemState.failed(error: TestError.error1)).notTo(equal(.failed(error: TestError.error2)))
    }

    func testSimilarity() {
        expect(ItemState.unknown).to(equal(.unknown, by: ~=))
        expect(ItemState.readyToPlay).to(equal(.readyToPlay, by: ~=))
        expect(ItemState.ended).to(equal(.ended, by: ~=))
        expect(ItemState.failed(error: TestError.any)).to(equal(.failed(error: TestError.any), by: ~=))
    }
}
