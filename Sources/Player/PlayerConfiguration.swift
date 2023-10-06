//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A player configuration.
public struct PlayerConfiguration {
    /// A Boolean value that indicates whether the player allows switching to external playback mode.
    public let allowsExternalPlayback: Bool

    /// A Boolean value that indicates whether the player allows switching to external playback when mirroring.
    ///
    /// This property has no effect when `allowsExternalPlayback` is false.
    public let usesExternalPlaybackWhileMirroring: Bool

    /// A Boolean indicating whether video playback prevents display and device sleep.
    public let preventsDisplaySleepDuringVideoPlayback: Bool

    /// A policy that determines how playback of audiovisual media continues when the app transitions
    /// to the background.
    public let audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy

    /// A Boolean controlling whether smart playlist navigation is enabled.
    ///
    /// See `returnToPrevious()` for more information.
    public let isSmartNavigationEnabled: Bool

    /// The forward skip interval in seconds.
    public let forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public let backwardSkipInterval: TimeInterval

    /// Creates a player configuration.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        preventsDisplaySleepDuringVideoPlayback: Bool = true,
        audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic,
        smartNavigationEnabled: Bool = true,
        backwardSkipInterval: TimeInterval = 10,
        forwardSkipInterval: TimeInterval = 10
    ) {
        assert(backwardSkipInterval > 0)
        assert(forwardSkipInterval > 0)
        self.allowsExternalPlayback = allowsExternalPlayback
        self.usesExternalPlaybackWhileMirroring = usesExternalPlaybackWhileMirroring
        self.preventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback
        self.audiovisualBackgroundPlaybackPolicy = audiovisualBackgroundPlaybackPolicy
        self.isSmartNavigationEnabled = smartNavigationEnabled
        self.backwardSkipInterval = backwardSkipInterval
        self.forwardSkipInterval = forwardSkipInterval
    }
}
