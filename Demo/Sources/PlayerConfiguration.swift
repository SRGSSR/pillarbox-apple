//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

extension PlayerConfiguration {
    static var standard: Self {
        PlayerConfiguration(
            allowsExternalPlayback: UserDefaults.standard.allowsExternalPlaybackEnabled,
            usesExternalPlaybackWhileMirroring: !UserDefaults.standard.presenterModeEnabled,
            audiovisualBackgroundPlaybackPolicy: UserDefaults.standard.audiovisualBackgroundPlaybackPolicy
        )
    }

    static var externalPlaybackDisabled: Self {
        PlayerConfiguration(
            allowsExternalPlayback: false,
            audiovisualBackgroundPlaybackPolicy: UserDefaults.standard.audiovisualBackgroundPlaybackPolicy
        )
    }
}
