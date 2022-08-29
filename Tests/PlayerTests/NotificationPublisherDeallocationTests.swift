//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

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
