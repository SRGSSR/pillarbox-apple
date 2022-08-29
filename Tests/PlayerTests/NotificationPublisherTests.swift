//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class NotificationPublisherTests: XCTestCase {
    func testWithoutObject() {
        let notificationCenter = NotificationCenter.default
        waitForOutput(from: notificationCenter.weakPublisher(for: .testNotification).first()) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }

    func testWithObject() {
        let object = TestObject()
        let notificationCenter = NotificationCenter.default
        waitForOutput(from: notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWithNSObject() {
        let object = TestNSObject()
        let notificationCenter = NotificationCenter.default
        waitForOutput(from: notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWithValueType() {
        let object = TestStruct()
        let notificationCenter = NotificationCenter.default
        waitForOutput(from: notificationCenter.weakPublisher(for: .testNotification).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testAfterObjectRelease() {
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
        expectNothingPublished(from: publisher, during: 1) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }
}
