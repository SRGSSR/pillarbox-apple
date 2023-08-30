//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionOption {
    var languageCode: String? {
        locale?.identifier
    }

    static func < (_ lhs: AVMediaSelectionOption, _ rhs: AVMediaSelectionOption) -> Bool {
        switch (lhs.hasMediaCharacteristic(.isOriginalContent), rhs.hasMediaCharacteristic(.isOriginalContent)) {
        case (true, false):
            return true
        case (false, true):
            return false
        default:
            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
    }
}
