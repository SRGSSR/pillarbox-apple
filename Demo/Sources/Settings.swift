//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

enum Settings {
    static func playerConfiguration() -> PlayerConfiguration {
        PlayerConfiguration(
            allowsExternalPlayback: UserDefaults.standard.allowsExternalPlaybackEnabled,
            usesExternalPlaybackWhileMirroring: !UserDefaults.standard.presenterModeEnabled
        )
    }

    static func playerConfigurationWithAirplayDisabled() -> PlayerConfiguration {
        PlayerConfiguration(
            allowsExternalPlayback: false
        )
    }
}
