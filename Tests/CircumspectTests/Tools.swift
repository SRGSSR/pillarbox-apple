//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import Foundation

enum TestError: Error {
    case any
}

struct NamedPerson: Similar {
    let name: String

    static func ~= (lhs: NamedPerson, rhs: NamedPerson) -> Bool {
        lhs.name.localizedCaseInsensitiveContains(rhs.name)
    }
}

extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}
