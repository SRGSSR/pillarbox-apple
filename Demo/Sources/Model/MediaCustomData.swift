//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct MediaCustomData: Hashable, Codable {
    let protection: Protection
    let isBuffered: Bool

    private let _startTime: Int64

    var startTime: CMTime {
        .init(value: _startTime, timescale: 1000)
    }

    init(protection: Protection, startTime: CMTime, isBuffered: Bool) {
        self.protection = protection
        self._startTime = Int64(startTime.seconds * 1000)
        self.isBuffered = isBuffered
    }
}
