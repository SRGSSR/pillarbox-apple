//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Playback progress.
public struct PlaybackProgress: Equatable {
    private static var defaultRange: ClosedRange<Float> = 0...1

    /// The current progress as a value in `bounds`.
    public var value: Float? {
        get { _value }
        set { _value = Self.sanitized(from: newValue) }
    }

    /// This value should be set to `true` when the value is updated interactively, e.g. via a seek bar. This informs
    /// the player that internal time updates must be suspended so that the interactive value is not updated to another
    /// value while interaction still takes place.
    public var isInteracting: Bool

    private var _value: Float?

    init(value: Float?, isInteracting: Bool) {
        _value = Self.sanitized(from: value)
        self.isInteracting = isInteracting
    }

    static var empty: Self {
        PlaybackProgress(value: nil, isInteracting: false)
    }

    public var bounds: ClosedRange<Float>? {
        return value != nil ? Self.defaultRange : nil
    }

    private static func sanitized(from value: Float?) -> Float? {
        return value?.clamped(to: Self.defaultRange)
    }
}
