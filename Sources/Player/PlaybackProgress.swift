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
    /// Set to `true` when updating progress interactively, e.g. via a seek bar.
    public var isInteracting: Bool
}
