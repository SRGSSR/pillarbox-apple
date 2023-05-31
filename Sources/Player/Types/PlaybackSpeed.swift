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

    static func desired(speed: Float) -> Self {
        .init(value: speed, range: 1...1)
    }

    static func actual(speed: Float, in range: ClosedRange<Float>) -> Self {
        .init(value: speed.clamped(to: range), range: range)
    }
}
