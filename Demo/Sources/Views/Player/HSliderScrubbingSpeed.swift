//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct StandardScrubbingSpeed: HSliderScrubbingSpeed {
    static var `default`: Self {
        .init()
    }

    var value: Double {
        1
    }

    private init() {}

    static func speed(forDistance distance: CGFloat) -> Self {
        .default
    }
}

/// Defines a scrubbing speed.
protocol HSliderScrubbingSpeed {
    /// The default scrubbing speed.
    static var `default`: Self { get }

    /// The (positive) associated numeric value.
    var value: Double { get }

    /// The speed to apply at a given distance from the slider.
    static func speed(forDistance distance: CGFloat) -> Self
}
