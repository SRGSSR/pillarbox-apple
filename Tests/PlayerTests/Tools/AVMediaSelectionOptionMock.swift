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
    private let _isOriginal: Bool

    init(displayName: String, isOriginal: Bool = false) {
        self._displayName = displayName
        self._isOriginal = isOriginal
        super.init()
    }

    override func hasMediaCharacteristic(_ mediaCharacteristic: AVMediaCharacteristic) -> Bool {
        _isOriginal
    }
}
