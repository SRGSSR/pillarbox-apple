//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum PlaybackSpeedUpdate: Equatable {
    case value(Float)
    case range(ClosedRange<Float>)
}

struct PlaybackSpeed: Equatable {
    static var indefinite: Self {
        .init(value: 1, range: 1...1)
    }

    let value: Float
    let range: ClosedRange<Float>

    var rate: Float {
        value.clamped(to: range)
    }

    init(value: Float, range: ClosedRange<Float>) {
        self.value = value
        self.range = range
    }

    func updated(with update: PlaybackSpeedUpdate) -> Self {
        if range == 1...1 {
            switch update {
            case let .value(speed):
                return .init(value: speed, range: range)
            case let .range(range):
                guard range != 1...1 else { return self }
                return .init(value: value.clamped(to: range), range: range)
            }
        }
        else {
            switch update {
            case let .value(speed):
                return .init(value: speed.clamped(to: range), range: range)
            case let .range(range):
                return .init(value: value.clamped(to: range), range: range)
            }
        }
    }
}
