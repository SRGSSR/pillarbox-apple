//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayerMediaSelectionCriteria {
    func selectionCriteria(byAdding preferredLanguages: [String], with preferredMediaCharacteristics: [AVMediaCharacteristic]) -> Self {
        let existingPreferredLanguages = self.preferredLanguages ?? []
        return Self(
            preferredLanguages: (preferredLanguages + existingPreferredLanguages).removeDuplicates(),
            preferredMediaCharacteristics: preferredMediaCharacteristics
        )
    }

    func selectionCriteria(byAdding preferredLanguages: [String]) -> Self {
        selectionCriteria(byAdding: preferredLanguages, with: preferredMediaCharacteristics ?? [])
    }
}
