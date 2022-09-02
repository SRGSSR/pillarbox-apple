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
    func testExpectPublishedValues() {
        expectEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectPublishedValuesWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectEqualPublished(
            values: [4, 7],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }
    }

    func testExpectPublishedNextValues() {
        expectEqualPublishedNext(
            values: [2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectPublishedNextValuesWhileExecuting() {
        let subject = PassthroughSubject<Int, Never>()
        expectEqualPublishedNext(
            values: [7, 8],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
            subject.send(completion: .finished)
        }
    }

    func testExpectPublishedValuesDuringInterval() {
        let counter = Counter()
        expectEqualPublished(
            values: [0, 1, 2],
            from: counter.$count,
            during: 0.5
        )
    }

    func testExpectPublishedValuesDuringIntervalWhileExecuting() {
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

    func testExpectPublishedNextValuesDuringInterval() {
        let counter = Counter()
        expectEqualPublishedNext(
            values: [1, 2],
            from: counter.$count,
            during: 0.5
        )
    }

    func testExpectPublishedNextValuesDuringIntervalWhileExecuting() {
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
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublished(from: subject, during: 1)
    }

    func testExpectNothingPublishedNext() {
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublishedNext(from: subject, during: 1) {
            subject.send(4)
        }
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

    func testExpectOnlyPublishedValues() {
        expectOnlyEqualPublished(
            values: [1, 2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectOnlyPublishedValuesWhileExecuting() {
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

    func testExpectOnlyPublishedNextValues() {
        expectOnlyEqualPublishedNext(
            values: [2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectOnlyPublishedNextValuesWhileExecuting() {
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
