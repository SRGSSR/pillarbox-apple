//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble

final class PositionTests: TestCase {
    func testPositionTo() {
        let position = to(CMTime(value: 1, timescale: 1), toleranceBefore: CMTime(value: 2, timescale: 1), toleranceAfter: CMTime(value: 3, timescale: 1))
        expect(position.time).to(equal(CMTime(value: 1, timescale: 1)))
        expect(position.toleranceBefore).to(equal(CMTime(value: 2, timescale: 1)))
        expect(position.toleranceAfter).to(equal(CMTime(value: 3, timescale: 1)))
    }

    func testPositionAt() {
        let position = at(CMTime(value: 1, timescale: 1))
        expect(position.time).to(equal(CMTime(value: 1, timescale: 1)))
        expect(position.toleranceBefore).to(equal(.zero))
        expect(position.toleranceAfter).to(equal(.zero))
    }

    func testPositionNear() {
        let position = near(CMTime(value: 1, timescale: 1))
        expect(position.time).to(equal(CMTime(value: 1, timescale: 1)))
        expect(position.toleranceBefore).to(equal(.positiveInfinity))
        expect(position.toleranceAfter).to(equal(.positiveInfinity))
    }

    func testPositionBefore() {
        let position = before(CMTime(value: 1, timescale: 1))
        expect(position.time).to(equal(CMTime(value: 1, timescale: 1)))
        expect(position.toleranceBefore).to(equal(.positiveInfinity))
        expect(position.toleranceAfter).to(equal(.zero))
    }

    func testPositionAfter() {
        let position = after(CMTime(value: 1, timescale: 1))
        expect(position.time).to(equal(CMTime(value: 1, timescale: 1)))
        expect(position.toleranceBefore).to(equal(.zero))
        expect(position.toleranceAfter).to(equal(.positiveInfinity))
    }
}
