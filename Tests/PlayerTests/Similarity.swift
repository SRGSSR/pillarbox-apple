//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Core
import CoreMedia
import Circumspect

func ~= (lhs: Error, rhs: Error) -> Bool {
    let lhsError = lhs as NSError
    let rhsError = rhs as NSError
    return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        && lhsError.localizedDescription == rhsError.localizedDescription
}

extension Pulse: Similar {
    public static func ~= (lhs: Pulse, rhs: Pulse) -> Bool {
        Pulse.close(within: CMTime(value: 1, timescale: 2))(lhs, rhs)
    }
}

extension ItemState: Similar {
    public static func ~= (lhs: ItemState, rhs: ItemState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.readyToPlay, .readyToPlay), (.ended, .ended):
            return true
        case let (.failed(error: lhsError), .failed(error: rhsError)):
            return lhsError ~= rhsError
        default:
            return false
        }
    }
}

extension PlaybackState: Similar {
    public static func ~= (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended):
            return true
        case let (.failed(error: lhsError), .failed(error: rhsError)):
            return lhsError ~= rhsError
        default:
            return false
        }
    }
}

extension AVPlayerItem: Similar {
    public static func ~= (lhs: AVPlayerItem, rhs: AVPlayerItem) -> Bool {
        if let lhsUrlAsset = lhs.asset as? AVURLAsset, let rhsUrlAsset = rhs.asset as? AVURLAsset {
            return lhsUrlAsset.url == rhsUrlAsset.url
        }
        else {
            return lhs == rhs
        }
    }
}

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    CMTime.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    CMTimeRange.close(within: tolerance)
}
