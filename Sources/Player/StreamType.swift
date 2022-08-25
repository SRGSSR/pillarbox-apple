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

    static func streamType(for item: AVPlayerItem?) -> StreamType {
        guard let item, let timeRange = Time.timeRange(for: item) else { return .unknown }
        return .onDemand
    }
}
