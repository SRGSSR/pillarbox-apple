//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import XCTest

final class ExpectNotificationsTests: XCTestCase {
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
}
