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

protocol HSliderScrubbingSpeed {
    static var `default`: Self { get }

    var value: Double { get }

    static func speed(forDistance distance: CGFloat) -> Self
}
