//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

extension PlayerConfiguration {
    static var standard: Self {
        let userDefaults = UserDefaults.standard
        return .init(
            usesExternalPlaybackWhileMirroring: !userDefaults.presenterModeEnabled,
            navigationMode: userDefaults.smartNavigationEnabled ? .smart(interval: 3) : .immediate,
            backwardSkipInterval: userDefaults.skipBackwardSetting,
            forwardSkipInterval: userDefaults.skipForwardSetting
        )
    }

    static var externalPlaybackDisabled: Self {
        let userDefaults = UserDefaults.standard
        return .init(
            allowsExternalPlayback: false,
            navigationMode: userDefaults.smartNavigationEnabled ? .smart(interval: 3) : .immediate
        )
    }
}
