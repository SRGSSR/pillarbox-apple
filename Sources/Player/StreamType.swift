//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

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
        return pulse.timeRange.isEmpty ? .live : .onDemand
    }
}
