//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

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
