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
        if !timeRange.isValid || !itemDuration.isValid {
            self = .unknown
        }
        else if timeRange.isEmpty && !itemDuration.isNumeric {
            self = .live
        }
        else if itemDuration.isIndefinite {
            self = .dvr
        }
        else {
            self = .onDemand
        }
    }
}
