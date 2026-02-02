//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Nimble
import PillarboxCircumspect
import XCTest

final class NotificationPublisherTests: XCTestCase {
    func testWithObject() throws {
        let object = TestObject()
        let notificationCenter = NotificationCenter.default
        try waitForOutput(from: notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWithNSObject() throws {
        let object = TestNSObject()
        let notificationCenter = NotificationCenter.default
        try waitForOutput(from: notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testAfterObjectRelease() {
        let notificationCenter = NotificationCenter.default
        var object: TestObject? = TestObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak let weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())

        // We were interested in notifications from `object` only. After its release we should not receive other
        // notifications from any other source anymore.
        expectNothingPublished(from: publisher, during: .seconds(1)) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }
}
