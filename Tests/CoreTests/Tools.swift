//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Use before tests using Nimble `throwAssertion()` which lead to crashes on tvOS if a debugger is attached, but
/// also to tests never finishing in general.
func nimbleThrowAssertionsEnabled() -> Bool {
    if ProcessInfo.processInfo.environment["tvOSNimbleThrowAssertionsEnabled"] == "true" {
        print("[INFO] This test contains Nimble throwing assertions and has been disabled.")
        return true
    }
    else {
        return false
    }
}

// swiftlint:disable file_types_order

final class TestNSObject: NSObject {
    let identifier: String

    init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
    }
}

final class TestObject {
    let identifier: String

    init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
    }
}

extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}

// swiftlint:enable file_types_order
