//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Playback progress.
public struct PlaybackProgress: Equatable {
    /// The current progress as a value in 0...1.
    public var value: Float
    /// This value should be set to `true` when the value is updated interactively, e.g. via a seek bar. This informs
    /// the player that internal time updates must be suspended so that the interactive value is not updated to another
    /// value while interaction still takes place.
    public var isInteracting: Bool
}
