//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// Actions that the player should perform when playback of an item reaches its end time.
public enum ActionAtItemEnd {
    /// Automatically advances to the next item in the queue.
    case advance

    /// Automatically pauses at the end of the item.
    case pause

    init(from actionAtItemEnd: AVPlayer.ActionAtItemEnd) {
        switch actionAtItemEnd {
        case .advance:
            self = .advance
        default:
            self = .pause
        }
    }

    func toAVPlayerActionAtItemEnd() -> AVPlayer.ActionAtItemEnd {
        switch self {
        case .advance:
            return .advance
        case .pause:
            return .pause
        }
    }
}
