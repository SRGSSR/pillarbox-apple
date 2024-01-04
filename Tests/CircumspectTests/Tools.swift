//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxCircumspect

struct StructError: Error {}

struct NamedPerson: Similar {
    let name: String

    static func ~~ (lhs: Self, rhs: Self) -> Bool {
        lhs.name.localizedCaseInsensitiveContains(rhs.name)
    }
}

extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}
