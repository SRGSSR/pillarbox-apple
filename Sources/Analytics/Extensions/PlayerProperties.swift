//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer

extension PlayerProperties {
    func endOffset() -> CMTime {
        seekableTimeRange.end - time()
    }
}
