//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

@objc
enum QualitySetting: Int, CaseIterable {
    case low
    case medium
    case high

    var name: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }

    var limits: PlayerLimits {
        switch self {
        case .low:
            return .init(preferredPeakBitRate: 500_000)
        case .medium:
            return .init(preferredPeakBitRate: 2_000_000)
        case .high:
            return .none
        }
    }
}
