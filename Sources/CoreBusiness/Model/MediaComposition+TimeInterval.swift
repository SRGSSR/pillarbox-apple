//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension MediaComposition {
    struct TimeInterval: Decodable {
        enum CodingKeys: String, CodingKey {
            case kind = "type"
            case _markIn = "markIn"
            case _markOut = "markOut"
        }

        public enum Kind: String, Decodable {
            case opening = "OPENING_CREDITS"
            case closing = "CLOSING_CREDITS"
        }

        public let kind: Kind

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
