//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    Time.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    Time.close(within: tolerance)
}
