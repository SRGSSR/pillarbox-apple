//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Nimble
import XCTest

final class ArrayTests: XCTestCase {
    func testRemoveDuplicates() {
        expect([1, 2, 3, 4].removeDuplicates()).to(equalDiff([1, 2, 3, 4]))
        expect([1, 2, 1, 4].removeDuplicates()).to(equalDiff([1, 2, 4]))
    }

    func testSafeIndex() {
        expect([1, 2, 3][safeIndex: 0]).to(equal(1))
        expect([1, 2, 3][safeIndex: -1]).to(beNil())
        expect([1, 2, 3][safeIndex: 3]).to(beNil())
    }
}
