//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@objc
enum SeekBehaviorSetting: Int, CaseIterable {
    case immediate
    case deferred

    var name: LocalizedStringKey {
        switch self {
        case .immediate:
            return "Immediate"
        case .deferred:
            return "Deferred"
        }
    }
}
