//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelections: Equatable {
    static var empty: Self {
        self.init(groups: [:])
    }

    let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]

    var characteristics: [AVMediaCharacteristic] {
        Array(groups.keys)
    }

    func options(withMediaCharacteristic characteristic: AVMediaCharacteristic) -> [AVMediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        return group.options
    }
}
