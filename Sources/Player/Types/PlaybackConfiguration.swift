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

    /// The position to start playback at.
    ///
    /// When the position time is `.zero`, playback efficiently starts at the default position:
    ///
    /// - Zero for an on-demand stream.
    /// - Live edge for a livestream supporting DVR.
    ///
    /// Note that starting at the default position is always efficient, no matter which tolerances have been requested.
    public let position: Position

    /// A Boolean value that indicates whether the player preserves its time offset from the live time after a
    /// buffering operation.
    public let automaticallyPreservesTimeOffsetFromLive: Bool

    /// The duration the player should buffer media from the network ahead of the playhead to guard against playback
    /// disruption.
    public let preferredForwardBufferDuration: TimeInterval

    /// A dictionary of custom HTTP header fields to be used when loading a player content.
    public let urlAssetHTTPHeaderFields: [String: String]

    /// Creates a playback configuration.
    public init(
        position: Position = at(.zero),
        automaticallyPreservesTimeOffsetFromLive: Bool = false,
        preferredForwardBufferDuration: TimeInterval = 0,
        urlAssetHTTPHeaderFields: [String: String] = [:]
    ) {
        self.position = position
        self.automaticallyPreservesTimeOffsetFromLive = automaticallyPreservesTimeOffsetFromLive
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
        self.urlAssetHTTPHeaderFields = urlAssetHTTPHeaderFields
    }

    func apply(to item: AVPlayerItem, with metadata: PlayerMetadata) {
        let position = position.after(metadata.blockedTimeRanges) ?? position
        item.seek(to: position.time, toleranceBefore: position.toleranceBefore, toleranceAfter: position.toleranceAfter, completionHandler: nil)
        item.automaticallyPreservesTimeOffsetFromLive = automaticallyPreservesTimeOffsetFromLive
        item.preferredForwardBufferDuration = preferredForwardBufferDuration
    }
}
