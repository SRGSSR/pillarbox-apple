//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// Manages display sleep prevention.
///
/// There is no real reliable way to manage `isIdleTimerDisabled` as soon as 3rd party code is involved, but this
/// class at least implements correct reference counting for the PillarboxPlayer framework. This ensures that the
/// idle timer is enabled most of the time, as written in `isIdleTimerDisabled` documentation.
final class DisplaySleep {
    static let shared = DisplaySleep()

    private var preventedCount = 0

    private init() {}

    func allow(for player: Player) {
        guard player.configuration.preventsDisplaySleepDuringVideoPlayback else { return }
        preventedCount -= 1
        if preventedCount == 0 {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    func prevent(for player: Player) {
        guard player.configuration.preventsDisplaySleepDuringVideoPlayback else { return }
        preventedCount += 1
        if preventedCount == 1 {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}
