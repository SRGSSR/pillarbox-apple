//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionGroup {
    func sortedOptions(withoutMediaCharacteristics characteristics: [AVMediaCharacteristic] = []) -> [MediaSelectionOption] {
        AVMediaSelectionGroup.mediaSelectionOptions(from: options, withoutMediaCharacteristics: characteristics)
            .sorted { lhsOption, rhsOption in
                lhsOption.displayName.localizedCaseInsensitiveCompare(rhsOption.displayName) == .orderedAscending
            }
            .map { .enabled($0) }
    }
}
