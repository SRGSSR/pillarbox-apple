//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A playback configuration.
public struct PlaybackConfiguration {
    /// The default configuration.
    public static let `default` = Self()

    private let position: () -> Position
    private let automaticallyPreservesTimeOffsetFromLive: Bool
    private let preferredForwardBufferDuration: TimeInterval

    /// Creates a playback configuration.
    ///
    /// - Parameters:
    ///   - position: The position to start playback at.
    ///   - automaticallyPreservesTimeOffsetFromLive: A Boolean value that indicates whether the player preserves its
    ///     time offset from the live time after a buffering operation.
    ///   - preferredForwardBufferDuration: The duration the player should buffer media from the network ahead of the
    ///     playhead to guard against playback disruption.
    ///
    /// When the position time is `.zero`, playback efficiently starts at the default position:
    ///
    /// - Zero for an on-demand stream.
    /// - Live edge for a livestream supporting DVR.
    ///
    /// > Note: Starting at the default position is always efficient, no matter which tolerances have been requested.
    public init(
        position: @escaping @autoclosure () -> Position = at(.zero),
        automaticallyPreservesTimeOffsetFromLive: Bool = false,
        preferredForwardBufferDuration: TimeInterval = 0
    ) {
        self.position = position
        self.automaticallyPreservesTimeOffsetFromLive = automaticallyPreservesTimeOffsetFromLive
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
    }

    func apply(to item: AVPlayerItem, with metadata: PlayerMetadata) {
        let position = position()
        let seekPosition = position.after(metadata.blockedTimeRanges) ?? position
        item.seek(to: seekPosition.time, toleranceBefore: seekPosition.toleranceBefore, toleranceAfter: seekPosition.toleranceAfter, completionHandler: nil)
        item.automaticallyPreservesTimeOffsetFromLive = automaticallyPreservesTimeOffsetFromLive
        item.preferredForwardBufferDuration = preferredForwardBufferDuration
    }
}
