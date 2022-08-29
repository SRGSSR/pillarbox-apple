//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class ClampedTests: XCTestCase {
    func testClamped() {
        expect((-1).clamped(to: 0...1)).to(equal(0))
        expect(0.clamped(to: 0...1)).to(equal(0))
        expect(0.5.clamped(to: 0...1)).to(equal(0.5))
        expect(1.clamped(to: 0...1)).to(equal(1))
        expect(2.clamped(to: 0...1)).to(equal(1))
    }
}

final class NotificationPublisherDeallocationTests: XCTestCase {
    func testReleaseWithObject() {
        let notificationCenter = NotificationCenter.default
        var object: TestObject? = TestObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        autoreleasepool {
            waitForOutput(from: publisher) {
                notificationCenter.post(name: .testNotification, object: object)
            }
            object = nil
        }
        expect(weakObject).to(beNil())
    }

    func testReleaseWithNSObject() {
        let notificationCenter = NotificationCenter.default
        var object: TestNSObject? = TestNSObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        autoreleasepool {
            waitForOutput(from: publisher) {
                notificationCenter.post(name: .testNotification, object: object)
            }
            object = nil
        }
        expect(weakObject).to(beNil())
    }
}

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
