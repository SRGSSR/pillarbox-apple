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

    override var locale: Locale? {
        _locale
    }

    private let _displayName: String
    private let _locale: Locale
    private let _characteristics: [AVMediaCharacteristic]

    init(displayName: String, languageCode: String = "", characteristics: [AVMediaCharacteristic] = []) {
        self._displayName = displayName
        self._locale = Locale(identifier: languageCode)
        self._characteristics = characteristics
        super.init()
    }

    override func hasMediaCharacteristic(_ mediaCharacteristic: AVMediaCharacteristic) -> Bool {
        _characteristics.contains(mediaCharacteristic)
    }
}
