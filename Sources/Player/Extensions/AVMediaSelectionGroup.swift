//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionGroup {
    static func sortedMediaSelectionOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        options.sorted(by: <)
    }

    static func sortedMediaSelectionOptions(
        from options: [AVMediaSelectionOption],
        withoutMediaCharacteristics characteristics: [AVMediaCharacteristic]
    ) -> [AVMediaSelectionOption] {
        mediaSelectionOptions(from: options, withoutMediaCharacteristics: characteristics).sorted(by: <)
    }
}

private extension AVMediaSelectionOption {
    static func < (_ lhs: AVMediaSelectionOption, _ rhs: AVMediaSelectionOption) -> Bool {
        lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
    }
}
