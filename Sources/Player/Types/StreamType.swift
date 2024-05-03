//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A stream type.
public enum StreamType {
    /// Unknown stream.
    case unknown

    /// On-demand stream.
    case onDemand

    /// Livestream without DVR.
    case live

    /// Livestream with DVR.
    case dvr

    init(for timeRange: CMTimeRange, duration: CMTime) {
        if !duration.isValid {
            self = .unknown
        }
        else if timeRange.isEmpty && !duration.isNumeric {
            self = .live
        }
        else if duration.isIndefinite {
            self = .dvr
        }
        else {
            self = .onDemand
        }
    }
}
