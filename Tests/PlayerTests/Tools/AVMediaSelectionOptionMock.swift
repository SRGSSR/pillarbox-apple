//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

class AVMediaSelectionOptionMock: AVMediaSelectionOption {
    override var displayName: String {
        _displayName
    }

    private let _displayName: String

    init(displayName: String) {
        self._displayName = displayName
        super.init()
    }
}
