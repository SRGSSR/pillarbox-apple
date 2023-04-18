//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Combine
import XCTest

final class ExpectOnlyPublishedTests: XCTestCase {
    func testExpectOnlyEqualPublishedValues() {
        expectOnlyEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectOnlyEqualPublishedValuesWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectOnlyEqualPublished(
            values: [4, 7],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }
    }

    func testExpectOnlyEqualPublishedNextValues() {
        expectOnlyEqualPublishedNext(
            values: [2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectOnlyEqualPublishedNextValuesWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectOnlyEqualPublishedNext(
            values: [7, 8],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
            subject.send(completion: .finished)
        }
    }
}
