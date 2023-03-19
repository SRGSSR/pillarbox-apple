//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

extension PlayerConfiguration {
    static var standard: Self {
        let userDefaults = UserDefaults.standard
        return .init(
            allowsExternalPlayback: userDefaults.allowsExternalPlaybackEnabled,
            usesExternalPlaybackWhileMirroring: !userDefaults.presenterModeEnabled,
            autoResumeAfterAnInterruption: userDefaults.autoResumeAfterAnInterruptionEnabled,
            audiovisualBackgroundPlaybackPolicy: userDefaults.audiovisualBackgroundPlaybackPolicy,
            smartNavigationEnabled: userDefaults.smartNavigationEnabled
        )
    }

    static var externalPlaybackDisabled: Self {
        let userDefaults = UserDefaults.standard
        return .init(
            allowsExternalPlayback: false,
            autoResumeAfterAnInterruption: userDefaults.autoResumeAfterAnInterruptionEnabled,
            audiovisualBackgroundPlaybackPolicy: userDefaults.audiovisualBackgroundPlaybackPolicy,
            smartNavigationEnabled: userDefaults.smartNavigationEnabled
        )
    }
}
