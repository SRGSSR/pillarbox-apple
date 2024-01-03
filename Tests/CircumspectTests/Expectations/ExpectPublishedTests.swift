//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Combine
import XCTest

final class ExpectPublishedTests: XCTestCase {
    func testExpectEqualPublishedValuesDuringInterval() {
        let counter = Counter()
        expectEqualPublished(
            values: [0, 1, 2],
            from: counter.$count,
            during: .milliseconds(500)
        )
    }

    func testExpectEqualPublishedValuesDuringIntervalWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectEqualPublished(
            values: [4, 7, 8],
            from: subject,
            during: .milliseconds(500)
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
        }
    }

    func testExpectEqualPublishedNextValuesDuringInterval() {
        let counter = Counter()
        expectEqualPublishedNext(
            values: [1, 2],
            from: counter.$count,
            during: .milliseconds(500)
        )
    }

    func testExpectEqualPublishedNextValuesDuringIntervalWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectEqualPublishedNext(
            values: [7, 8],
            from: subject,
            during: .milliseconds(500)
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
        }
    }
}
