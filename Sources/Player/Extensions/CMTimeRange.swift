//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension CMTimeRange {
    static func flatten(_ timeRanges: [CMTimeRange]) -> [CMTimeRange] {
        timeRanges.sorted { $0.start < $1.start }.reduce(into: [CMTimeRange]()) { result, timeRange in
            if let lastTimeRange = result.last {
                if timeRange.containsTime(lastTimeRange.end) {
                    result[result.count - 1] = lastTimeRange.union(timeRange)
                }
                else if !lastTimeRange.containsTimeRange(timeRange) {
                    result.append(timeRange)
                }
            }
            else {
                result.append(timeRange)
            }
        }
    }
}
