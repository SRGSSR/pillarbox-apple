//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum BlockingReason: String, Decodable {
    case ageRating12 = "AGERATING12"
    case ageRating18 = "AGERATING18"
    case commercial = "COMMERCIAL"
    case endDate = "ENDDATE"
    case geoblocked = "GEOBLOCK"
    case legal = "LEGAL"
    case startDate = "STARTDATE"
    case unknown = "UNKNOWN"

    public var description: String {
        switch self {
        case .ageRating12:
            return "To protect children, this media is only available between 8PM and 6AM."
        case .ageRating18:
            return "To protect children, this media is only available between 10PM and 5AM."
        case .commercial:
            return "This commercial media is not available."
        case .endDate:
            return "This media is not available anymore."
        case .geoblocked:
            return "This media is not available outside Switzerland."
        case .legal:
            return "This media is not available due to legal restrictions."
        case .startDate:
            return "This media is not available yet. Please try again later."
        case .unknown:
            return "This media is not available."
        }
    }
}
