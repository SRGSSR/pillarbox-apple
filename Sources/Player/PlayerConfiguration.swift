//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A player configuration.
public struct PlayerConfiguration {
    /// The default configuration.
    public static let `default` = Self()

    /// A Boolean value that indicates whether the player allows switching to external playback mode.
    public let allowsExternalPlayback: Bool

    /// A Boolean value that indicates whether the player allows switching to external playback when mirroring.
    ///
    /// This property has no effect when `allowsExternalPlayback` is `false`.
    public let usesExternalPlaybackWhileMirroring: Bool

    /// A Boolean indicating whether video playback prevents display and device sleep.
    public let preventsDisplaySleepDuringVideoPlayback: Bool

    /// A Boolean controlling whether smart playlist navigation is enabled.
    ///
    /// See `returnToPrevious()` for more information.
    public let isSmartNavigationEnabled: Bool

    /// The forward skip interval in seconds.
    public let forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public let backwardSkipInterval: TimeInterval

    /// The number of items to preload.
    let preloadedItems = 2

    /// Creates a player configuration.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        preventsDisplaySleepDuringVideoPlayback: Bool = true,
        smartNavigationEnabled: Bool = true,
        backwardSkipInterval: TimeInterval = 10,
        forwardSkipInterval: TimeInterval = 10
    ) {
        assert(backwardSkipInterval > 0)
        assert(forwardSkipInterval > 0)
        self.allowsExternalPlayback = allowsExternalPlayback
        self.usesExternalPlaybackWhileMirroring = usesExternalPlaybackWhileMirroring
        self.preventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback
        self.isSmartNavigationEnabled = smartNavigationEnabled
        self.backwardSkipInterval = backwardSkipInterval
        self.forwardSkipInterval = forwardSkipInterval
    }
}
