//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// Manages the available media selections as well as the currently selected one.
struct MediaSelector: Equatable {
    static var empty: Self {
        self.init(groups: [:])
    }

    let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    func options(withMediaCharacteristic characteristic: AVMediaCharacteristic) -> [AVMediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        return group.options
    }
}
