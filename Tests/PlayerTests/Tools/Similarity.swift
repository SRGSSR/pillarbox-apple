//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import PillarboxCircumspect
import UIKit

extension ImageSource: Similar {
    public static func ~~ (lhs: ImageSource, rhs: ImageSource) -> Bool {
        switch (lhs.kind, rhs.kind) {
        case (.none, .none):
            return true
        case let (.url(lhsUrl), .url(rhsUrl)):
            return lhsUrl == rhsUrl
        case let (.image(lhsImage), .image(rhsImage)):
            return lhsImage.pngData() == rhsImage.pngData()
        default:
            return false
        }
    }
}

extension Resource: Similar {
    public static func ~~ (lhs: PillarboxPlayer.Resource, rhs: PillarboxPlayer.Resource) -> Bool {
        switch (lhs, rhs) {
        case let (.simple(url: lhsUrl), .simple(url: rhsUrl)),
            let (.custom(url: lhsUrl, delegate: _), .custom(url: rhsUrl, delegate: _)),
            let (.encrypted(url: lhsUrl, delegate: _), .encrypted(url: rhsUrl, delegate: _)):
            return lhsUrl == rhsUrl
        default:
            return false
        }
    }
}

extension NowPlaying.Info: Similar {
    public static func ~~ (lhs: Self, rhs: Self) -> Bool {
        // swiftlint:disable:next legacy_objc_type
        NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
}

extension MetricEvent: Similar {
    public static func ~~ (lhs: MetricEvent, rhs: MetricEvent) -> Bool {
        switch (lhs.kind, rhs.kind) {
        case (.assetLoading, .assetLoading), (.resourceLoading, .resourceLoading), (.failure, .failure), (.warning, .warning):
            return true
        default:
            return false
        }
    }
}

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    CMTime.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTime?, CMTime?) -> Bool) {
    CMTime.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    CMTimeRange.close(within: tolerance)
}
