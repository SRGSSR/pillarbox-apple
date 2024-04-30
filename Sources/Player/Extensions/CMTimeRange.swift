//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension CMTimeRange {
    static func flatten(_ timeRanges: [CMTimeRange]) -> [CMTimeRange] {
        timeRanges.sorted { $0.start < $1.start }.reduce(into: [CMTimeRange]()) { mergedResult, timeRange in
            if let lastTimeRange = mergedResult.last {
                if timeRange.containsTime(lastTimeRange.end) {
                    mergedResult[mergedResult.count - 1] = lastTimeRange.union(timeRange)
                }
                else if !lastTimeRange.containsTimeRange(timeRange) {
                    mergedResult.append(timeRange)
                }
            }
            else {
                mergedResult.append(timeRange)
            }
        }
    }
}
