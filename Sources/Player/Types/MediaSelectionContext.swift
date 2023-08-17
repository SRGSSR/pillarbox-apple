//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

struct MediaSelectionContext {
    static var empty: Self {
        self.init(groups: [:], selection: nil)
    }

    let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]
    let selection: AVMediaSelection?

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    func selectedOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let selection, let group = groups[characteristic] else { return nil }
        return selection.selectedMediaOption(in: group)
    }

    func otherSelectedOptions(for characteristic: AVMediaCharacteristic) -> [AVMediaCharacteristic: AVMediaSelectionOption] {
        guard let selection else { return [:] }
        return .init(uniqueKeysWithValues: characteristics
            .compactMap { otherCharacteristic -> (AVMediaCharacteristic, AVMediaSelectionOption)? in
                guard otherCharacteristic != characteristic, let group = groups[otherCharacteristic],
                      let option = selection.selectedMediaOption(in: group) else {
                    return nil
                }
                return (otherCharacteristic, option)
            })
    }
}
