//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension MediaComposition {
    /// A content blocking reason.
    enum BlockingReason {
        /// Not suitable under the age of 12.
        case ageRating12

        /// Not suitable under the age of 18.
        case ageRating18

        /// Commercial reason.
        case commercial

        /// Not available anymore.
        case endDate(Date?)

        /// Geoblocked.
        case geoblocked

        /// Journalistic reason.
        case journalistic

        /// Legal reason.
        case legal

        /// Not available yet.
        case startDate(Date?)

        /// Unknown reason.
        case unknown

        /// VPN or proxy detected.
        case vpnOrProxyDetected

        /// The standard description for the blocking reason.
        public var description: String {
            switch self {
            case .ageRating12:
                return String(
                    localized: "To protect children this content is only available between 8PM and 6AM.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .ageRating18:
                return String(
                    localized: "To protect children this content is only available between 10PM and 5AM.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .commercial:
                return String(
                    localized: "This commercial content is not available.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .endDate:
                return String(
                    localized: "This content is not available anymore.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .geoblocked:
                return String(
                    localized: "This content is not available outside Switzerland.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .journalistic:
                return String(
                    localized: "This content is temporarily unavailable for journalistic reasons.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .legal:
                return String(
                    localized: "This content is not available due to legal restrictions.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .startDate:
                return String(
                    localized: "This content is not available yet.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .unknown:
                return String(
                    localized: "This content is not available.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            case .vpnOrProxyDetected:
                return String(
                    localized: "This content cannot be played while using a VPN or a proxy.",
                    bundle: .module,
                    comment: "Blocking reason description message"
                )
            }
        }
    }
}

extension MediaComposition {
    // swiftlint:disable:next type_name
    enum _BlockingReason: String, Decodable {
        case ageRating12 = "AGERATING12"
        case ageRating18 = "AGERATING18"
        case commercial = "COMMERCIAL"
        case endDate = "ENDDATE"
        case geoblocked = "GEOBLOCK"
        case journalistic = "JOURNALISTIC"
        case legal = "LEGAL"
        case startDate = "STARTDATE"
        case unknown = "UNKNOWN"
        case vpnOrProxyDetected = "VPNORPROXYDETECTED"

        // swiftlint:disable:next cyclomatic_complexity
        func blockingReason(startDate: Date?, endDate: Date?) -> BlockingReason {
            switch self {
            case .ageRating12:
                .ageRating12
            case .ageRating18:
                .ageRating18
            case .commercial:
                .commercial
            case .endDate:
                .endDate(endDate)
            case .geoblocked:
                .geoblocked
            case .journalistic:
                .journalistic
            case .legal:
                .legal
            case .startDate:
                .startDate(startDate)
            case .unknown:
                .unknown
            case .vpnOrProxyDetected:
                .vpnOrProxyDetected
            }
        }
    }
}
