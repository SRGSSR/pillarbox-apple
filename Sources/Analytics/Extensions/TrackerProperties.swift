//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer

extension TrackerProperties {
    func endOffset() -> CMTime {
        max(seekableTimeRange.end - time, .zero)
    }
}
