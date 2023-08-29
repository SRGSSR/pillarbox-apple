//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Core

extension AVPlayerMediaSelectionCriteria {
    func adding(preferredLanguages languages: [String]) -> Self {
        let existingPreferredLanguages = preferredLanguages ?? []
        return Self(
            preferredLanguages: (languages + existingPreferredLanguages).removeDuplicates(),
            preferredMediaCharacteristics: preferredMediaCharacteristics
        )
    }
}
