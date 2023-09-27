//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import MediaAccessibility

enum MediaAccessibilityDisplayType {
    case automatic
    case forcedOnly
    case alwaysOn(languageCode: String)

    func apply() {
        switch self {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
        case .forcedOnly:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
        case let .alwaysOn(languageCode: languageCode):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
        }
    }
}
