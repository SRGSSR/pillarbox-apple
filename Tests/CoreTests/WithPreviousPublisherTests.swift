//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Combine
import XCTest

final class WithPreviousPublisherTests: XCTestCase {
    func testPreviousValues() {
        expectEqualPublished(
            values: [nil, 1, 2, 3, 4],
            from: (1...5).publisher.withPrevious().map(\.previous),
            during: 1
        )
    }

    func testCurrentValues() {
        expectEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: (1...5).publisher.withPrevious().map(\.current),
            during: 1
        )
    }

    func testOptionalPreviousValues() {
        expectEqualPublished(
            values: [-1, 1, 2, 3, 4],
            from: (1...5).publisher.withPrevious(-1).map(\.previous),
            during: 1
        )
    }

    func testOptionalCurrentValues() {
        expectEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: (1...5).publisher.withPrevious(-1).map(\.current),
            during: 1
        )
    }
}
