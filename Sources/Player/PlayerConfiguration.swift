//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// Player configuration.
public struct PlayerConfiguration {
    /// A Boolean value that indicates whether the player allows switching to external playback mode.
    public let allowsExternalPlayback: Bool

    /// A Boolean value that indicates whether the player allows switching to external playback when mirroring.
    /// This property has no effect when `allowsExternalPlayback` is false.
    public let usesExternalPlaybackWhileMirroring: Bool

    /// Indicates whether video playback prevents display and device sleep.
    public let preventsDisplaySleepDuringVideoPlayback: Bool

    /// A Boolean value that indicates whether the player should automatically resume playback after an interruption ends.
    public let autoResumeAfterAnInterruption: Bool

    /// A policy that determines how playback of audiovisual media continues when the app transitions
    /// to the background.
    public let audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy

    /// Enables smart playlist navigation (calling `returnToPrevious()` returns to the previous item in a playlist
    /// only within its first few seconds, otherwise resumes the current item at its beginning).
    public let isSmartNavigationEnabled: Bool

    /// The forward skip interval in seconds.
    public let forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public let backwardSkipInterval: TimeInterval

    /// Create a player configuration.
    /// - Parameters:
    ///   - allowsExternalPlayback: Allows switching to external playback mode.
    ///   - usesExternalPlaybackWhileMirroring: Allows switching to external playback when mirroring.
    ///   - preventsDisplaySleepDuringVideoPlayback: Indicates whether video playback prevents display and device sleep.
    ///   - autoResumeAfterAnInterruption: A Boolean value that indicates whether the player should automatically resume playback
    ///     after an interruption ends.
    ///   - audiovisualBackgroundPlaybackPolicy: Policy that determines how playback of audiovisual media continues
    ///     when the app transitions to the background.
    ///   - smartNavigationEnabled: Enables smart playlist navigation (see `isSmartNavigationEnabled`).
    ///   - backwardSkipInterval: The forward skip interval in seconds.
    ///   - forwardSkipInterval: The backward skip interval in seconds.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        preventsDisplaySleepDuringVideoPlayback: Bool = true,
        autoResumeAfterAnInterruption: Bool = false,
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
        self.autoResumeAfterAnInterruption = autoResumeAfterAnInterruption
        self.audiovisualBackgroundPlaybackPolicy = audiovisualBackgroundPlaybackPolicy
        self.isSmartNavigationEnabled = smartNavigationEnabled
        self.backwardSkipInterval = backwardSkipInterval
        self.forwardSkipInterval = forwardSkipInterval
    }
}
