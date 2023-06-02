//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct PlaybackSpeed: Equatable {
    let value: Float
    let range: ClosedRange<Float>

    var rate: Float {
        value.clamped(to: range)
    }

    private init(value: Float, range: ClosedRange<Float>) {
        self.value = value
        self.range = range
    }

    static func desired(speed: Float) -> Self {
        .init(value: speed, range: 1...1)
    }

    static func actual(speed: Float, in range: ClosedRange<Float>) -> Self {
        .init(value: speed.clamped(to: range), range: range)
    }

    func updated(with other: Self) -> Self {
        if other.range == 1...1 {
            if range == 1...1 {
                return other
            }
            else {
                return .actual(speed: other.value, in: range)
            }
        }
        else {
            return .actual(speed: value, in: other.range)
        }
    }
}
