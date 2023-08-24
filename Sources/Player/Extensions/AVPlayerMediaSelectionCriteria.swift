//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

// TODO: Remove duplicates

extension AVPlayerMediaSelectionCriteria {
    func adding(preferredLanguages languages: [String]) -> Self {
        let preferredLanguages = self.preferredLanguages ?? []
        return Self(
            preferredLanguages: languages + preferredLanguages,
            preferredMediaCharacteristics: self.preferredMediaCharacteristics
        )
    }
}
