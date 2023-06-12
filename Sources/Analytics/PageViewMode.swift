//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A mode for which page views must be measured.
public enum PageViewMode {
    /// A mode allowing page views both in foreground and background.
    ///
    /// You must avoid measuring page views when your application is in background, except in very specific use cases
    /// (e.g. measuring a CarPlay user interface while the main application is in background).
    case foregroundAndBackground
    /// A mode allowing page views in foreground only.
    ///
    /// Page views must only be measured when your application is in background. This is therefore the recommended mode
    /// for most applications.
    case foreground
}
