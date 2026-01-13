//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public enum MarkRange: Hashable {
    case time(CMTimeRange)
    case date(DateInterval)

    func start() -> Mark {
        switch self {
        case let .time(timeRange):
            .time(timeRange.start)
        case let .date(dateInterval):
            .date(dateInterval.start)
        }
    }

    func end() -> Mark {
        switch self {
        case let .time(timeRange):
            .time(timeRange.end)
        case let .date(dateInterval):
            .date(dateInterval.end)
        }
    }

    func duration() -> CMTime {
        switch self {
        case let .time(timeRange):
            timeRange.duration
        case let .date(dateInterval):
            CMTime(seconds: dateInterval.duration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
    }

    func containsMark(_ mark: Mark) -> Bool {
        switch (self, mark) {
        case let (.time(timeRange), .time(time)):
            timeRange.containsTime(time)
        case let (.date(dateInterval), .date(date)):
            dateInterval.contains(date)
        default:
            false
        }
    }

    func timeRange() -> CMTimeRange? {
        switch self {
        case let .time(timeRange):
            timeRange
        case .date:
            nil
        }
    }

    func dateInterval() -> DateInterval? {
        switch self {
        case .time:
            nil
        case let .date(dateInterval):
            dateInterval
        }
    }
}
