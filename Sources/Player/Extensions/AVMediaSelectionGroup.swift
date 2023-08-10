//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionGroup {
    var sortedOptions: [AVMediaSelectionOption] {
        options.sorted { lhsOption, rhsOption in
            lhsOption.displayName.localizedCaseInsensitiveCompare(rhsOption.displayName) == .orderedAscending
        }
    }
}
