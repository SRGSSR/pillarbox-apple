//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Combine
import Nimble
import XCTest

final class ExpectationTests: XCTestCase {
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

    func testExpectNothingPublished() {
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublished(from: subject, during: .seconds(1))
    }

    func testExpectNothingPublishedNext() {
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublishedNext(from: subject, during: .seconds(1)) {
            subject.send(4)
        }
    }

    func testExpectSuccess() {
        expectSuccess(from: Empty<Int, Error>())
    }

    func testExpectFailure() {
        expectFailure(from: Fail<Int, Error>(error: StructError()))
    }

    func testExpectFailureWithError() {
        expectFailure(StructError(), from: Fail<Int, Error>(error: StructError()))
    }

    func testExpectAtLeastReceivedNotifications() {
        expectAtLeastReceived(
            notifications: [
                Notification(name: .testNotification, object: self)
            ],
            for: [.testNotification]
        ) {
            NotificationCenter.default.post(name: .testNotification, object: self)
        }
    }

    func testExpectReceivedNotificationsDuringInterval() {
        expectReceived(
            notifications: [
                Notification(name: .testNotification, object: self)
            ],
            for: [.testNotification],
            during: .milliseconds(500)
        ) {
            NotificationCenter.default.post(name: .testNotification, object: self)
        }
    }

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
