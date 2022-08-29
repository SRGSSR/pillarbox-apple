//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Circumspect

extension Pulse: Similar {
    public static func ~= (lhs: Pulse, rhs: Pulse) -> Bool {
        Pulse.close(within: 0.5)(lhs, rhs)
    }
}

extension PlaybackProperties: Similar {
    public static func ~= (lhs: PlaybackProperties, rhs: PlaybackProperties) -> Bool {
        PlaybackProperties.close(within: 0.5)(lhs, rhs)
    }
}

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    CMTime.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    CMTimeRange.close(within: tolerance)
}
