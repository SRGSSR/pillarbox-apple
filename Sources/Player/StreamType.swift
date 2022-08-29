//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

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

    static func streamType(for pulse: Pulse?) -> StreamType {
        guard let pulse else { return .unknown }
        if pulse.timeRange.isEmpty {
            return .live
        }
        else {
            let itemDuration = pulse.itemDuration
            if itemDuration.isIndefinite {
                return .dvr
            }
            else {
                return itemDuration == .zero ? .live : .onDemand
            }
        }
    }
}
