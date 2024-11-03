//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@objc
enum SeekBehaviorSetting: Int, CaseIterable {
    case immediate
    case deferred

    var name: String {
        switch self {
        case .immediate:
            return "Immediate"
        case .deferred:
            return "Deferred"
        }
    }
}
