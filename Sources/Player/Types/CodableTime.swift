//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct CodableTime: Codable, Hashable {
    private let value: CMTimeValue
    private let timeScale: CMTimeScale

    var time: CMTime {
        .init(value: value, timescale: timeScale)
    }

    init(from time: CMTime) {
        self.value = time.value
        self.timeScale = time.timescale
    }
}
