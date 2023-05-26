//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum PlaybackSpeed {
    case desired(speed: Float)
    case actual(speed: Float, in: ClosedRange<Float>)

    var value: Float {
        input.clamped(to: range)
    }

    var range: ClosedRange<Float> {
        switch self {
        case .desired:
            return 1...1
        case let .actual(_, range):
            return range
        }
    }

    var input: Float {
        switch self {
        case let .desired(speed), let .actual(speed, _):
            return speed
        }
    }
}
