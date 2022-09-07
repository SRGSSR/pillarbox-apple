//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import Foundation

/// Playback progress.
public struct PlaybackProgress: Equatable {
    /// Seek behavior during progress updates.
    public enum SeekBehavior {
        /// Seek immediately when updated.
        case immediate
        /// Deferred until interaction ends (see `isInteracting`).
        case deferred
    }

    static var empty: Self {
        PlaybackProgress(value: nil, isInteracting: false)
    }

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

    /// Progress lower and upper bounds, if any.
    public var bounds: ClosedRange<Float>? {
        value != nil ? Self.defaultRange : nil
    }

    init(value: Float?, isInteracting: Bool) {
        _value = Self.sanitized(from: value)
        self.isInteracting = isInteracting
    }

    private static func sanitized(from value: Float?) -> Float? {
        value?.clamped(to: Self.defaultRange)
    }
}

extension PlaybackProgress: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let value else { return "No progress" }
        return String(format: "Progress: %.2f", value)
    }
}
