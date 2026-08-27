//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A player configuration.
///
/// The configuration controls behaviors set at player creation time and that cannot be changed afterwards.
public struct PlayerConfiguration {
    /// The default configuration.
    public static let `default` = Self()

    /// A Boolean value that indicates whether the player allows switching to external playback mode.
    public var allowsExternalPlayback: Bool

    /// A Boolean value that indicates whether the player allows switching to external playback when mirroring.
    ///
    /// This property has no effect when `allowsExternalPlayback` is `false`.
    public var usesExternalPlaybackWhileMirroring: Bool

    /// A Boolean indicating whether video playback prevents display and device sleep.
    public var preventsDisplaySleepDuringVideoPlayback: Bool

    /// The navigation mode.
    public var navigationMode: NavigationMode

    /// The forward skip interval in seconds.
    public var forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public var backwardSkipInterval: TimeInterval

    /// A Boolean value indicating whether the player is permitted to play content on networks with Low Data Mode
    /// enabled.
    ///
    /// When this property is set to `false`, playback fails with a network availability error on constrained networks.
    /// This option is therefore mostly useful for players associated with non-essential content, such as animated
    /// background videos used purely for visual enhancement.
    public var allowsConstrainedNetworkAccess: Bool

    /// The number of items to preload.
    let preloadedItems = 2

    /// Creates a player configuration.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        preventsDisplaySleepDuringVideoPlayback: Bool = true,
        navigationMode: NavigationMode = .smart(interval: 3),
        backwardSkipInterval: TimeInterval = 10,
        forwardSkipInterval: TimeInterval = 10,
        allowsConstrainedNetworkAccess: Bool = true
    ) {
        assert(backwardSkipInterval > 0)
        assert(forwardSkipInterval > 0)
        self.allowsExternalPlayback = allowsExternalPlayback
        self.usesExternalPlaybackWhileMirroring = usesExternalPlaybackWhileMirroring
        self.preventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback
        self.navigationMode = navigationMode
        self.backwardSkipInterval = backwardSkipInterval
        self.forwardSkipInterval = forwardSkipInterval
        self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
    }

    /// The skip interval for some direction, in seconds.
    public func interval(forSkip skip: Skip) -> TimeInterval {
        switch skip {
        case .backward:
            return backwardSkipInterval
        case .forward:
            return forwardSkipInterval
        }
    }
}
