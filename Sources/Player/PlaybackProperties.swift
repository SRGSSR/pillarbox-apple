//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Combine

/// Playback properties.
struct PlaybackProperties {
    static var empty: Self {
        PlaybackProperties(pulse: nil, targetTime: nil)
    }

    /// Pulse.
    let pulse: Pulse?

    /// Time targeted by a pending seek, if any.
    let targetTime: CMTime?

    /// A value in 0...1 describing the playback progress targeted by a pending seek, if any.
    var targetProgress: Float? {
        guard let targetTime, let targetProgress = pulse?.progress(for: targetTime) else {
            return pulse?.progress
        }
        return targetProgress
    }

    static func close(within tolerance: CMTime) -> ((PlaybackProperties, PlaybackProperties) -> Bool) {
        return { properties1, properties2 in
            Pulse.close(within: tolerance)(properties1.pulse, properties2.pulse)
                && CMTime.close(within: tolerance)(properties1.targetTime, properties2.targetTime)
        }
    }
}
