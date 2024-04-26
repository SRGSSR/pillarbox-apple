//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension MediaComposition {
    /// A content blocking reason.
    enum BlockingReason: String, Decodable {
        /// Not suitable under the age of 12.
        case ageRating12 = "AGERATING12"

        /// Not suitable under the age of 18.
        case ageRating18 = "AGERATING18"

        /// Commercial reason.
        case commercial = "COMMERCIAL"

        /// Content is not available anymore.
        case endDate = "ENDDATE"

        /// Content is geoblocked.
        case geoblocked = "GEOBLOCK"

        /// Legal reason.
        case legal = "LEGAL"

        /// Content is not available yet.
        case startDate = "STARTDATE"

        /// Unknown reason.
        case unknown = "UNKNOWN"

        /// The standard description for the blocking reason.
        public var description: String {
            switch self {
            case .ageRating12:
                return NSLocalizedString(
                    "To protect children this content is only available between 8PM and 6AM.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .ageRating18:
                return NSLocalizedString(
                    "To protect children this content is only available between 10PM and 5AM.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .commercial:
                return NSLocalizedString(
                    "This commercial content is not available.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .endDate:
                return NSLocalizedString(
                    "This content is not available anymore.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .geoblocked:
                return NSLocalizedString(
                    "This content is not available outside Switzerland.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .legal:
                return NSLocalizedString(
                    "This content is not available due to legal restrictions.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .startDate:
                return NSLocalizedString(
                    "This content is not available yet.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .unknown:
                return NSLocalizedString(
                    "This content is not available.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            }
        }
    }
}
