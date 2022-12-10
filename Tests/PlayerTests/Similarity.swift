//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import CoreMedia

extension Asset: Similar {
    public static func ~= (lhs: Asset, rhs: Asset) -> Bool {
        switch (lhs, rhs) {
        case let (.simple(url: lhsUrl), .simple(url: rhsUrl)):
            return lhsUrl == rhsUrl
        case let (.custom(url: lhsUrl, delegate: _), .custom(url: rhsUrl, delegate: _)):
            return lhsUrl == rhsUrl
        case let (.encrypted(url: lhsUrl, delegate: _), .encrypted(url: rhsUrl, delegate: _)):
            return lhsUrl == rhsUrl
        default:
            return false
        }
    }
}

func beClose(within tolerance: Float) -> ((Float, Float) -> Bool) {
    { lhs, rhs in
        fabsf(lhs - rhs) <= tolerance
    }
}

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    CMTime.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    CMTimeRange.close(within: tolerance)
}
