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

extension Pulse: Similar {
    public static func ~= (lhs: Pulse, rhs: Pulse) -> Bool {
        Pulse.close(within: CMTime(value: 1, timescale: 2))(lhs, rhs)
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
