//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Player

extension ComScoreTracker.Metadata {
    static var test: Self {
        test(streamType: .unknown)
    }

    static func test(streamType: StreamType) -> Self {
        .init(labels: ["meta": "data"], streamType: streamType)
    }
}
