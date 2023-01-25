//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

/// Stream types.
public enum StreamType {
    /// Not yet determined.
    case unknown
    /// On-demand stream.
    case onDemand
    /// Livestream without DVR.
    case live
    /// Livestream with DVR.
    case dvr

    init(for timeRange: CMTimeRange, itemDuration: CMTime) {
        switch (timeRange, itemDuration) {
        case (.invalid, _), (_, .invalid):
            self = .unknown
        case (let TimeRange, _) where TimeRange.isEmpty:
            self = .live
        case (_, let ItemDuration) where ItemDuration.isIndefinite:
            self = .dvr
        default:
            self = .onDemand
        }
    }
}
