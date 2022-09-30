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
}
