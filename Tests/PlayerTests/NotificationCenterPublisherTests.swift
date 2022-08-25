//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//


@testable import Player

import Circumspect
import Nimble
import XCTest

final class NotificationCenterPublisherTests: XCTestCase {
    func testWithoutObject() throws {
        let notificationCenter = NotificationCenter.default
        try awaitCompletion(from: notificationCenter.weakPublisher(for: .testNotification).first()) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }

    func testWithObject() throws {
        let object = TestObject()
        let notificationCenter = NotificationCenter.default
        try awaitCompletion(from: notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWithNSObject() throws {
        let object = TestNSObject()
        let notificationCenter = NotificationCenter.default
        try awaitCompletion(from: notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWithValueType() throws {
        let object = TestStruct()
        let notificationCenter = NotificationCenter.default
        try awaitCompletion(from: notificationCenter.weakPublisher(for: .testNotification).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testAfterObjectRelease() throws {
        let notificationCenter = NotificationCenter.default
        var object: TestObject? = TestObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())

        // We were interested in notifications from `object` only. After its release we should not receive other
        // notifications from any other source anymore.
        try expectNothingPublished(from: publisher, during: 1) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }
}

final class NotificationCenterPublisherDeallocationTests: XCTestCase {
    func testReleaseWithObject() throws {
        let notificationCenter = NotificationCenter.default
        var object: TestObject? = TestObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        _ = try autoreleasepool {
            try awaitCompletion(from: publisher) {
                notificationCenter.post(name: .testNotification, object: object)
            }
            object = nil
        }
        expect(weakObject).to(beNil())
    }

    func testReleaseWithNSObject() throws {
        let notificationCenter = NotificationCenter.default
        var object: TestNSObject? = TestNSObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        _ = try autoreleasepool {
            try awaitCompletion(from: publisher) {
                notificationCenter.post(name: .testNotification, object: object)
            }
            object = nil
        }
        expect(weakObject).to(beNil())
    }
}
