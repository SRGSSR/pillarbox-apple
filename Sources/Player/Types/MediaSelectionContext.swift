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
}
