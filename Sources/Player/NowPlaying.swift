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

extension NowPlaying.Info {
    static func merge(_ lhs: NowPlaying.Info?, _ rhs: NowPlaying.Info?) -> NowPlaying.Info? {
        let lhs = lhs ?? [:]
        let rhs = rhs ?? [:]
        let nowPlayingInfo = lhs.merging(rhs) { _, new in new }
        return !nowPlayingInfo.isEmpty ? nowPlayingInfo : nil
    }
}
