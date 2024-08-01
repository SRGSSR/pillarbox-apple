//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension TimeInterval {
    init(from stride: DispatchQueue.SchedulerTimeType.Stride) {
        switch stride.timeInterval {
        case let .seconds(time):
            self = TimeInterval(time)
        case let .milliseconds(time):
            self = TimeInterval(time) / 1_000
        case let .microseconds(time):
            self = TimeInterval(time) / 1_000_000
        case let .nanoseconds(time):
            self = TimeInterval(time) / 1_000_000_000
        default:
            self = .nan
        }
    }
}
