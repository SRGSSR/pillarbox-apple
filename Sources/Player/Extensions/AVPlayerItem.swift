//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVPlayerItem {
    /// Seeks to a given position.
    ///
    /// - Parameter position: The position to seek to.
    ///
    /// This method can be used to start playback of an `AVPlayerItem` at some arbitrary position. If the position is
    /// `.zero` playback efficiently starts at the default position:
    ///
    /// - Zero for an on-demand stream.
    /// - Live edge for a livestream supporting DVR.
    ///
    /// Note that starting at the default position is always efficient, no matter which tolerances have been requested.
    func seek(_ position: Position) {
        seek(to: position.time, toleranceBefore: position.toleranceBefore, toleranceAfter: position.toleranceAfter, completionHandler: nil)
    }
}

extension AVPlayerItem {
    var timeRange: CMTimeRange {
        TimeProperties.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    static func playerItems(from items: [PlayerItem], length: Int, fresh: Bool) -> [AVPlayerItem] {
        playerItems(from: items.prefix(length).map(\.asset), fresh: fresh)
    }
}
