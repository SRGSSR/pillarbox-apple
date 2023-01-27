//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

enum NowPlaying {
    typealias Info = [String: Any]

    struct Properties {
        let timeRange: CMTimeRange
        let itemDuration: CMTime
        let isBuffering: Bool
    }
}
