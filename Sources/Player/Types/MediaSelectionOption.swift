//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public enum MediaSelectionOption: Hashable {
    case automatic
    case disabled
    case enabled(AVMediaSelectionOption)

    public var displayName: String {
        switch self {
        case .automatic:
            return "Auto (Recommended)"
        case .disabled:
            return "Off"
        case let .enabled(option):
            return option.displayName
        }
    }
}
