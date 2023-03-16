//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Dispatch

extension DispatchTimeInterval {
    func double() -> Double {
        switch self {
        case let .seconds(value):
            return Double(value)
        case let .milliseconds(value):
            return Double(value) * 0.001
        case let .microseconds(value):
            return Double(value) * 0.000001
        case let .nanoseconds(value):
            return Double(value) * 0.000000001
        default:
            return 0
        }
    }
}
