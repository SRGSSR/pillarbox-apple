//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@objc
enum RoutePickerSetting: Int, CaseIterable {
    case button
    case menu

    var name: LocalizedStringResource {
        switch self {
        case .button:
            return "Button"
        case .menu:
            return "Menu"
        }
    }
}
