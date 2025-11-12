//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@objc
enum SeekBehaviorSetting: Int, CaseIterable {
    case optimal
    case deferred

    var name: LocalizedStringResource {
        switch self {
        case .optimal:
            return "Optimal"
        case .deferred:
            return "Deferred"
        }
    }
}
