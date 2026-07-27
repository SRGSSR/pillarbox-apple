//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Scrubbing: ScrubbingSpeed, Equatable {
    case highSpeed
    case halfSpeed
    case quarterSpeed
    case fine

    static var `default`: Self {
        .highSpeed
    }

    var value: Double {
        switch self {
        case .highSpeed:
            return 1
        case .halfSpeed:
            return 0.5
        case .quarterSpeed:
            return 0.25
        case .fine:
            return 0.1
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .highSpeed:
            return "High-Speed Scrubbing"
        case .halfSpeed:
            return "Half-Speed Scrubbing"
        case .quarterSpeed:
            return "Quarter-Speed Scrubbing"
        case .fine:
            return "Fine Scrubbing"
        }
    }

    static func speed(forDistance distance: CGFloat) -> Self {
        switch distance {
        case 0..<50:
            return .highSpeed
        case 50..<100:
            return .halfSpeed
        case 100..<150:
            return .quarterSpeed
        default:
            return .fine
        }
    }
}
