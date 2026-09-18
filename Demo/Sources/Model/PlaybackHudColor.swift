//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum PlaybackHudColor: Int, CaseIterable, CustomLocalizedStringResourceConvertible {
    case yellow
    case green
    case red
    case blue
    case white

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .white:
            return "White"
        }
    }
}
