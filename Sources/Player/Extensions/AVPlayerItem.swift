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
    /// This method can be used to start playback of an `AVPlayerItem` at some position.
    func seek(_ position: Position) {
        seek(to: position.time, toleranceBefore: position.toleranceBefore, toleranceAfter: position.toleranceAfter, completionHandler: nil)
    }
}

extension AVPlayerItem {
    var timeRange: CMTimeRange {
        TimeProperties.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    static func playerItems(from items: [PlayerItem]) -> [AVPlayerItem] {
        playerItems(from: items.map(\.asset))
    }
}
