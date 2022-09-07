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

    /// The minimum duration below which a DVR window is collapsed to zero (so that the stream
    /// is effectively seen as a livestream without DVR). Defaults to `.zero`.
    public var dvrThreshold: CMTime {
        get { _dvrThreshold }
        set { _dvrThreshold = CMTimeMaximum(newValue, .zero) }
    }

    /// Seek behavior during progress updates.
    public var seekBehavior: PlaybackProgress.SeekBehavior = .immediate

    private var _tick = CMTime(value: 1, timescale: 1)
    private var _dvrThreshold = CMTime.zero
}
