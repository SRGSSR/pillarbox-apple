//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class TestNSObject: NSObject {}

final class TestObject {
    let identifier: String

    init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
    }
}

extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}
