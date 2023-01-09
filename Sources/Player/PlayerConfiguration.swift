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

    /// Create a player configuration.
    /// - Parameter allowsExternalPlayback: Allows switching to external playback mode.
    public init(allowsExternalPlayback: Bool = true) {
        self.allowsExternalPlayback = allowsExternalPlayback
    }
}
