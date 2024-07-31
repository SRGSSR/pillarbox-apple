//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension TimeInterval {
    init(from stride: DispatchQueue.SchedulerTimeType.Stride) {
        switch stride.timeInterval {
        case .seconds(let time):
            self = TimeInterval(time)
        case .milliseconds(let time):
            self = TimeInterval(time) / 1_000
        case .microseconds(let time):
            self = TimeInterval(time) / 1_000_000
        case .nanoseconds(let time):
            self = TimeInterval(time) / 1_000_000_000
        default:
            self = .nan
        }
    }
}
