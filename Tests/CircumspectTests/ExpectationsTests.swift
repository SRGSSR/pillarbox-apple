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
    func testExpectPublishedValues() throws {
        try expectPublished(
            values: [1, 2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectPublishedValuesWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Never>()
        try expectPublished(
            values: [4, 7],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(completion: .finished)
        }
    }

    func testExpectPublishedNextValues() throws {
        try expectPublishedNext(
            values: [2, 3, 4, 5],
            from: [1, 2, 3, 4, 5].publisher
        )
    }

    func testExpectPublishedNextValuesWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Never>()
        try expectPublishedNext(
            values: [7, 8],
            from: subject
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
            subject.send(completion: .finished)
        }
    }

    func testExpectPublishedValuesDuringInterval() throws {
        let counter = Counter()
        try expectPublished(
            values: [0, 1, 2],
            from: counter.$count,
            during: 0.5
        )
    }

    func testExpectPublishedValuesDuringIntervalWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Never>()
        try expectPublished(
            values: [4, 7, 8],
            from: subject,
            during: 0.5
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
        }
    }

    func testExpectPublishedNextValuesDuringInterval() throws {
        let counter = Counter()
        try expectPublishedNext(
            values: [1, 2],
            from: counter.$count,
            during: 0.5
        )
    }

    func testExpectPublishedNextValuesDuringIntervalWhileExecuting() throws {
        let subject = PassthroughSubject<Int, Never>()
        try expectPublishedNext(
            values: [7, 8],
            from: subject,
            during: 0.5
        ) {
            subject.send(4)
            subject.send(7)
            subject.send(8)
        }
    }

    func testExpectNothingPublished() throws {
        let subject = PassthroughSubject<Int, Never>()
        try expectNothingPublished(from: subject, during: 1)
    }

    func testExpectNothingPublishedNext() throws {
        let subject = PassthroughSubject<Int, Never>()
        try expectNothingPublishedNext(from: subject, during: 1) {
            subject.send(4)
        }
    }

    func testExpectReceivedNotifications() throws {
        try expectReceived(
            notifications: [
                Notification(name: .testNotification, object: self)
            ],
            for: [.testNotification]
        ) {
            NotificationCenter.default.post(name: .testNotification, object: self)
        }
    }

    func testExpectReceivedNotificationsDuringInterval() throws {
        try expectReceived(
            notifications: [
                Notification(name: .testNotification, object: self)
            ],
            for: [.testNotification],
            during: 0.5
        ) {
            NotificationCenter.default.post(name: .testNotification, object: self)
        }
    }
}
