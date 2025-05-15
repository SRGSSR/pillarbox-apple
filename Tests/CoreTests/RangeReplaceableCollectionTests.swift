//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Nimble
import PillarboxCircumspect
import XCTest

final class RangeReplaceableCollectionTests: XCTestCase {
    func testMoveForward() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        array.move(from: 2, to: 5)
        expect(array).to(equalDiff([1, 2, 4, 5, 3, 6, 7]))
    }

    func testMoveBackward() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        array.move(from: 5, to: 2)
        expect(array).to(equalDiff([1, 2, 6, 3, 4, 5, 7]))
    }

    func testMoveToEnd() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        array.move(from: 2, to: 7)
        expect(array).to(equalDiff([1, 2, 4, 5, 6, 7, 3]))
    }

    func testMoveSameItem() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        array.move(from: 2, to: 2)
        expect(array).to(equalDiff([1, 2, 3, 4, 5, 6, 7]))
    }

    func testMoveFromInvalidIndex() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
        var array = [1, 2, 3, 4, 5, 6, 7]
        expect(array.move(from: -1, to: 2)).to(throwAssertion())
        expect(array.move(from: 8, to: 2)).to(throwAssertion())
    }

    func testMoveToInvalidIndex() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
        var array = [1, 2, 3, 4, 5, 6, 7]
        expect(array.move(from: 2, to: -1)).to(throwAssertion())
        expect(array.move(from: 2, to: 8)).to(throwAssertion())
    }
}
