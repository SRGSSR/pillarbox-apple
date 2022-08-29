//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public struct PlayerConfiguration {
    public var tick: CMTime {
        get { _tick }
        set { _tick = CMTimeMaximum(newValue, CMTime(value: 1, timescale: 10)) }
    }

    public var dvrThreshold: CMTime {
        get { _dvrThreshold }
        set { _dvrThreshold = CMTimeMaximum(newValue, .zero) }
    }

    private var _tick = CMTime(value: 1, timescale: 1)
    private var _dvrThreshold = CMTime.zero
}
