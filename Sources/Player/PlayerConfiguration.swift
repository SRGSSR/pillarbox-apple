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

    /// A policy that determines how playback of audiovisual media continues when the app transitions
    /// to the background.
    public let audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy

    /// Create a player configuration.
    /// - Parameters:
    ///   - allowsExternalPlayback: Allows switching to external playback mode.
    ///   - usesExternalPlaybackWhileMirroring: Allows switching to external playback when mirroring.
    ///   - audiovisualBackgroundPlaybackPolicy: Policy that determines how playback of audiovisual
    ///   media continues when the app transitions to the background.
    public init(
        allowsExternalPlayback: Bool = true,
        usesExternalPlaybackWhileMirroring: Bool = false,
        audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic
    ) {
        self.allowsExternalPlayback = allowsExternalPlayback
        self.usesExternalPlaybackWhileMirroring = usesExternalPlaybackWhileMirroring
        self.audiovisualBackgroundPlaybackPolicy = audiovisualBackgroundPlaybackPolicy
    }
}
