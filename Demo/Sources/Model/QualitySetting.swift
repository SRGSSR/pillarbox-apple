//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

@objc
enum QualitySetting: Int, CaseIterable, CustomLocalizedStringResourceConvertible {
    case low
    case medium
    case high

    var localizedStringResource: LocalizedStringResource {
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
        .init(preferredPeakBitRate: preferredPeakBitRate)
    }

    var preferredPeakBitRate: Double {
        switch self {
        case .low:
            return 500_000
        case .medium:
            return 2_000_000
        case .high:
            return 0
        }
    }
}
