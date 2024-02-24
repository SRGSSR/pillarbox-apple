//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct PlaybackSpeed: Equatable {
    static let indefinite = Self(value: 1, range: nil)

    let value: Float
    let range: ClosedRange<Float>?

    var effectiveValue: Float {
        range != nil ? value : 1
    }

    var effectiveRange: ClosedRange<Float> {
        range ?? 1...1
    }

    init(value: Float, range: ClosedRange<Float>?) {
        if let range {
            self.value = value.clamped(to: range)
        }
        else {
            self.value = value
        }
        self.range = range
    }

    func updated(with update: PlaybackSpeedUpdate) -> Self {
        switch update {
        case let .value(value):
            return .init(value: value, range: range)
        case let .range(range) where range == nil:
            return .init(value: 1, range: range)
        case let .range(range):
            return .init(value: value, range: range)
        }
    }
}
