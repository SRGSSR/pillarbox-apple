//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@objc
enum SeekBehaviorSetting: Int, CaseIterable, CustomLocalizedStringResourceConvertible {
    case optimal
    case deferred

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .optimal:
            return "Optimal"
        case .deferred:
            return "Deferred"
        }
    }
}
