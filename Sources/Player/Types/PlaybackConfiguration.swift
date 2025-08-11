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

    /// The position to consistently start playback of the item at.
    ///
    /// If `.zero` is provided, playback starts efficiently at the default position:
    ///
    /// - Zero for on-demand streams.
    /// - Live edge for DVR-enabled livestreams.
    ///
    /// > Note: Resuming at the default position is always efficient, regardless of the requested tolerances.
    public let position: Position

    /// A Boolean value that indicates whether the player preserves its time offset from the live time after a
    /// buffering operation.
    public let automaticallyPreservesTimeOffsetFromLive: Bool

    /// The duration the player should buffer media from the network ahead of the playhead to guard against playback
    /// disruption.
    public let preferredForwardBufferDuration: TimeInterval

    /// Creates a playback configuration.
    public init(
        position: Position = at(.zero),
        automaticallyPreservesTimeOffsetFromLive: Bool = false,
        preferredForwardBufferDuration: TimeInterval = 0
    ) {
        self.position = position
        self.automaticallyPreservesTimeOffsetFromLive = automaticallyPreservesTimeOffsetFromLive
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
    }

    func apply(to item: AVPlayerItem, with metadata: PlayerMetadata, resumePosition: Position?) {
        let position = position.after(metadata.blockedTimeRanges) ?? position
        item.seek(
            to: position.time,
            toleranceBefore: position.toleranceBefore,
            toleranceAfter: position.toleranceAfter,
            completionHandler: nil
        )
        item.automaticallyPreservesTimeOffsetFromLive = automaticallyPreservesTimeOffsetFromLive
        item.preferredForwardBufferDuration = preferredForwardBufferDuration
    }
}
