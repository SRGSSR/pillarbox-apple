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
        // swiftlint:disable:next private_subject
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
        // swiftlint:disable:next private_subject
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
            during: 0.5
        )
    }

    func testExpectEqualPublishedValuesDuringIntervalWhileExecuting() {
        // swiftlint:disable:next private_subject
        let subject = PassthroughSubject<Int, Never>()
        expectEqualPublished(
            values: [4, 7, 8],
            from: subject,
            during: 0.5
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
            during: 0.5
        )
    }

    func testExpectEqualPublishedNextValuesDuringIntervalWhileExecuting() {
        // swiftlint:disable:next private_subject
        let subject = PassthroughSubject<Int, Never>()
        expectEqualPublishedNext(
            values: [7, 8],
            from: subject,
            during: 0.5
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
        }
    }

    func testExpectNothingPublished() {
        // swiftlint:disable:next private_subject
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublished(from: subject, during: 1)
    }

    func testExpectNothingPublishedNext() {
        // swiftlint:disable:next private_subject
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublishedNext(from: subject, during: 1) {
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

    func testExpectReceivedNotifications() {
        expectReceived(
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
            during: 0.5
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
        // swiftlint:disable:next private_subject
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
        // swiftlint:disable:next private_subject
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
