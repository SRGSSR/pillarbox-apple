//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Player configuration.
public struct PlayerConfiguration {
    /// A Boolean value that indicates whether the player allows switching to external playback mode.
    public let allowsExternalPlayback: Bool

    /// A Boolean value that indicates whether the player allows to switch to external plaback mode even though the screen mirroring is enable.
    /// This property has no effect when `allowsExternalPlayback` is false.
    public let usesExternalPlaybackWhileExternalScreenIsActive: Bool

    /// Create a player configuration.
    /// - Parameters:
    ///   - allowsExternalPlayback: Allows switching to external playback mode.
    ///   - usesExternalPlaybackWhileExternalScreenIsActive: Allows the external playback usage during a screen mirroring.
    public init(allowsExternalPlayback: Bool = true, usesExternalPlaybackWhileExternalScreenIsActive: Bool = false) {
        self.allowsExternalPlayback = allowsExternalPlayback
        self.usesExternalPlaybackWhileExternalScreenIsActive = usesExternalPlaybackWhileExternalScreenIsActive
    }
}
