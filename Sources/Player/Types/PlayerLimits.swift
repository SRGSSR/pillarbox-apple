//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreGraphics

/// A set of limits applied by the player during playback.
public struct PlayerLimits {
    /// No limits.
    public static let none = Self()

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

    /// Creates a set of limits.
    public init(
        preferredPeakBitRate: Double = 0,
        preferredPeakBitRateForExpensiveNetworks: Double = 0,
        preferredMaximumResolution: CGSize = .zero,
        preferredMaximumResolutionForExpensiveNetworks: CGSize = .zero
    ) {
        self.preferredPeakBitRate = preferredPeakBitRate
        self.preferredPeakBitRateForExpensiveNetworks = preferredPeakBitRateForExpensiveNetworks
        self.preferredMaximumResolution = preferredMaximumResolution
        self.preferredMaximumResolutionForExpensiveNetworks = preferredMaximumResolutionForExpensiveNetworks
    }

    func apply(to playerItem: AVPlayerItem) {
        playerItem.preferredPeakBitRate = preferredPeakBitRate
        playerItem.preferredPeakBitRateForExpensiveNetworks = preferredPeakBitRateForExpensiveNetworks
        playerItem.preferredMaximumResolution = preferredMaximumResolution
        playerItem.preferredMaximumResolutionForExpensiveNetworks = preferredMaximumResolutionForExpensiveNetworks
    }

    func apply(to playerItems: [AVPlayerItem]) {
        playerItems.forEach { playerItem in
            apply(to: playerItem)
        }
    }
}
