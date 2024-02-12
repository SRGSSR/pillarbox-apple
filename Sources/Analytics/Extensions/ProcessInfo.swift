//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension ProcessInfo {
    var isDesktopApp: Bool {
        isMacCatalystApp || isiOSAppOnMac
    }
}
