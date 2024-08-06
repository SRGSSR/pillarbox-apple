//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension ProcessInfo {
    /// A Boolean value that indicates whether the process is running on a Mac.
    var isRunningOnMac: Bool {
        isMacCatalystApp || isiOSAppOnMac
    }
}
