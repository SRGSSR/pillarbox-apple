//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionGroup {
    static func sortedMediaSelectionOptions(
        from options: [AVMediaSelectionOption]
    ) -> [AVMediaSelectionOption] {
        options
            .sorted { lhsOption, rhsOption in
                lhsOption.displayName.localizedCaseInsensitiveCompare(rhsOption.displayName) == .orderedAscending
            }
    }

    static func sortedMediaSelectionOptions(
        from options: [AVMediaSelectionOption],
        withoutMediaCharacteristics characteristics: [AVMediaCharacteristic]
    ) -> [AVMediaSelectionOption] {
        mediaSelectionOptions(from: options, withoutMediaCharacteristics: characteristics)
            .sorted { lhsOption, rhsOption in
                lhsOption.displayName.localizedCaseInsensitiveCompare(rhsOption.displayName) == .orderedAscending
            }
    }
}
