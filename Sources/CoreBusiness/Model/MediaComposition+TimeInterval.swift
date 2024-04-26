//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension MediaComposition {
    /// A time interval.
    struct TimeInterval: Decodable {
        enum CodingKeys: String, CodingKey {
            case kind = "type"
            case _markIn = "markIn"
            case _markOut = "markOut"
        }

        /// A kind of time interval.
        public enum Kind: String, Decodable {
            /// Openning credits.
            case openingCredits = "OPENING_CREDITS"

            /// Closing credits.
            case closingCredits = "CLOSING_CREDITS"
        }

        /// The kind of interval.
        public let kind: Kind

        /// The associated time range.
        public var timeRange: CMTimeRange {
            CMTimeRange(
                start: .init(value: _markIn, timescale: 1000),
                end: .init(value: _markOut, timescale: 1000)
            )
        }

        private let _markIn: Int64
        private let _markOut: Int64
    }
}
