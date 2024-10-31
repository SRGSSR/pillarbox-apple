//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreGraphics
import Foundation

/// A player configuration.
///
/// The configuration controls behaviors set at player creation time and that cannot be changed afterwards.
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

    /// The navigation mode.
    public let navigationMode: NavigationMode

    /// The forward skip interval in seconds.
    public let forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public let backwardSkipInterval: TimeInterval

    /// The number of items to preload.
    let preloadedItems = 2

    /// A Boolean value that indicates whether the player is allowed to play content on networks enabled for Low Data
    /// Mode.
    ///
    /// A player which cannot is not allowed access to constrained networks will report the network as being
    /// unreachable. You should only enable this option on players which play non-essential content, e.g. animated
    /// background videos.
    public let allowsConstrainedNetworkAccess: Bool

    /// A limit of network bandwidth consumption observed by the player on all networks.
    ///
    /// Disabled when set to zero.
    public let preferredPeakBitRate: Double

    /// A limit of network bandwidth consumption observed by the player when connecting over
    /// [expensive networks](https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/3235752-allowsexpensivenetworkaccess).
    ///
    /// Disabled when set to zero.
    public let preferredPeakBitRateForExpensiveNetworks: Double

    /// A limit of resolution observed by the player on all networks.
    ///
    /// Disabled when set to `.zero`.
    public let preferredMaximumResolution: CGSize

    /// A limit of resolution observed by the player when connecting over
    /// [expensive networks](https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/3235752-allowsexpensivenetworkaccess).
    ///
    /// Disabled when set to `.zero`.
    public let preferredMaximumResolutionForExpensiveNetworks: CGSize

    /// Creates a player configuration.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        preventsDisplaySleepDuringVideoPlayback: Bool = true,
        navigationMode: NavigationMode = .smart(interval: 3),
        backwardSkipInterval: TimeInterval = 10,
        forwardSkipInterval: TimeInterval = 10,
        allowsConstrainedNetworkAccess: Bool = true,
        preferredPeakBitRate: Double = 0,
        preferredPeakBitRateForExpensiveNetworks: Double = 0,
        preferredMaximumResolution: CGSize = .zero,
        preferredMaximumResolutionForExpensiveNetworks: CGSize = .zero
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
        self.preferredPeakBitRate = preferredPeakBitRate
        self.preferredPeakBitRateForExpensiveNetworks = preferredPeakBitRateForExpensiveNetworks
        self.preferredMaximumResolution = preferredMaximumResolution
        self.preferredMaximumResolutionForExpensiveNetworks = preferredMaximumResolutionForExpensiveNetworks
    }
}
