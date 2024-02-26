//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

extension PlayerConfiguration {
    static let standard = Self(
        usesExternalPlaybackWhileMirroring: !UserDefaults.standard.presenterModeEnabled,
        smartNavigationEnabled: UserDefaults.standard.smartNavigationEnabled
    )

    static let externalPlaybackDisabled = Self(
        allowsExternalPlayback: false,
        smartNavigationEnabled: UserDefaults.standard.smartNavigationEnabled
    )
}
