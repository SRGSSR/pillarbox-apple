//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import Foundation

extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}

struct NamedPerson: Similar {
    static func ~= (lhs: NamedPerson, rhs: NamedPerson) -> Bool {
        return lhs.name.localizedCaseInsensitiveContains(rhs.name)
    }

    let name: String
}
