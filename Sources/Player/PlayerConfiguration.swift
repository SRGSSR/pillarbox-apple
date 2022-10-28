//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Player configuration.
public struct PlayerConfiguration {
    /// The interval at which the player internally ticks. Defaults to 1 second, minimum is 1/10th second.
    public var tick: CMTime {
        get { _tick }
        set { _tick = CMTimeMaximum(newValue, CMTime(value: 1, timescale: 10)) }
    }

    /// Seek behavior during progress updates. Default is `.immediate`.
    public var seekBehavior: PlaybackProgress.SeekBehavior = .immediate

    private var _tick = CMTime(value: 1, timescale: 1)
}
