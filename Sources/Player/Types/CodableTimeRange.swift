//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct CodableTimeRange: Codable, Hashable {
    private let _start: CodableTime
    private let _duration: CodableTime

    var timeRange: CMTimeRange {
        .init(start: start, duration: duration)
    }

    var start: CMTime {
        _start.time
    }

    var end: CMTime {
        timeRange.end
    }

    var duration: CMTime {
        _duration.time
    }

    init(start: CMTime, duration: CMTime) {
        _start = .init(from: start)
        _duration = .init(from: duration)
    }

    init(start: CMTime, end: CMTime) {
        self.init(start: start, duration: end - start)
    }

    init(from timeRange: CMTimeRange) {
        self.init(start: timeRange.start, duration: timeRange.duration)
    }

    func containsTime(_ time: CMTime) -> Bool {
        timeRange.containsTime(time)
    }
}
