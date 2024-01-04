//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Combine
import XCTest

final class ExpectAtLeastPublishedTests: XCTestCase {
    func testExpectAtLeastEqualPublishedValues() {
        expectAtLeastEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectAtLeastEqualPublishedValuesWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectAtLeastEqualPublished(
            values: [4, 7],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }
    }

    func testExpectAtLeastEqualPublishedNextValues() {
        expectAtLeastEqualPublishedNext(
            values: [2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectAtLeastEqualPublishedNextValuesWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectAtLeastEqualPublishedNext(
            values: [7, 8],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
            subject.send(completion: .finished)
        }
    }

    func testExpectAtLeastEqualFollowingExpectEqual() {
        let publisher = PassthroughSubject<Int, Never>()
        expectEqualPublished(values: [1, 2], from: publisher, during: .milliseconds(100)) {
            publisher.send(1)
            publisher.send(2)
        }
        expectAtLeastEqualPublished(values: [3, 4, 5], from: publisher) {
            publisher.send(3)
            publisher.send(4)
            publisher.send(5)
        }
    }
}
