//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

final class WithPreviousPublisherTests: XCTestCase {
    func testEmpty() {
        expectNothingPublished(from: Empty<Int, Never>().withPrevious(), during: .seconds(1))
    }

    func testPreviousValues() {
        expectAtLeastEqualPublished(
            values: [nil, 1, 2, 3, 4],
            from: (1...5).publisher.withPrevious().map(\.previous)
        )
    }

    func testCurrentValues() {
        expectAtLeastEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: (1...5).publisher.withPrevious().map(\.current)
        )
    }

    func testOptionalPreviousValues() {
        expectAtLeastEqualPublished(
            values: [-1, 1, 2, 3, 4],
            from: (1...5).publisher.withPrevious(-1).map(\.previous)
        )
    }

    func testOptionalCurrentValues() {
        expectAtLeastEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: (1...5).publisher.withPrevious(-1).map(\.current)
        )
    }
}
