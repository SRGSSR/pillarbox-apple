//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct StandardScrubbingSpeed: ScrubbingSpeed {
    static var `default`: Self {
        .init()
    }

    var value: Double {
        1
    }

    static func speed(forDistance distance: CGFloat) -> Self {
        .default
    }
}

/// Defines a scrubbing speed.
protocol ScrubbingSpeed {
    /// The default scrubbing speed.
    static var `default`: Self { get }

    /// The (positive) associated numeric value.
    var value: Double { get }

    /// The speed to apply at a given distance from the slider.
    static func speed(forDistance distance: CGFloat) -> Self
}
