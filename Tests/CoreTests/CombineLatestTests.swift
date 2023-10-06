//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Combine
import XCTest

final class CombineLatestPublisherTests: XCTestCase {
    func testOutput5() {
        expectOnlyEqualPublished(
            values: [
                [1, 2, 3, 4, 5]
            ],
            from: Publishers.CombineLatest5(
                Just(1),
                Just(2),
                Just(3),
                Just(4),
                Just(5)
            )
            .map { [$0.0, $0.1, $0.2, $0.3, $0.4] }
        )
    }

    func testOutput6() {
        expectOnlyEqualPublished(
            values: [
                [1, 2, 3, 4, 5, 6]
            ],
            from: Publishers.CombineLatest6(
                Just(1),
                Just(2),
                Just(3),
                Just(4),
                Just(5),
                Just(6)
            )
            .map { [$0.0, $0.1, $0.2, $0.3, $0.4, $0.5] }
        )
    }

    func testOutput7() {
        expectOnlyEqualPublished(
            values: [
                [1, 2, 3, 4, 5, 6, 7]
            ],
            from: Publishers.CombineLatest7(
                Just(1),
                Just(2),
                Just(3),
                Just(4),
                Just(5),
                Just(6),
                Just(7)
            )
            .map { [$0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6] }
        )
    }
}
