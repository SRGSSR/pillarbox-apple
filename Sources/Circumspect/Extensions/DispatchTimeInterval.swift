//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Dispatch

public extension DispatchTimeInterval {
    /// Transforms the receiver into a double.
    func double() -> Double {
        switch self {
        case let .seconds(value):
            return .init(value)
        case let .milliseconds(value):
            return .init(value) * 1e-3
        case let .microseconds(value):
            return .init(value) * 1e-6
        case let .nanoseconds(value):
            return .init(value) * 1e-9
        default:
            return 0
        }
    }
}
