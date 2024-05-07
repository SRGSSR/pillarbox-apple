//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// An option for media selection (audible, legible, etc.).
public enum MediaSelectionOption: Hashable {
    /// Automatic selection based on system language and accessibility settings.
    case automatic

    /// Disabled.
    ///
    /// Options might still be forced where applicable.
    case off

    /// Enabled.
    ///
    /// You can extract `AVMediaSelectionOption` characteristics for display purposes.
    case on(AVMediaSelectionOption)

    /// A name suitable for display.
    public var displayName: String {
        switch self {
        case .automatic:
            return String(localized: "Auto (Recommended)", bundle: .module, comment: "Subtitle selection option")
        case .off:
            return String(localized: "Off", bundle: .module, comment: "Subtitle selection option")
        case let .on(option):
            return option.displayName
        }
    }
}
