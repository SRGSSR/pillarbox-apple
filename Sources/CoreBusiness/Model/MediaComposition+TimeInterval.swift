//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension MediaComposition {
    struct TimeInterval: Decodable {
        enum CodingKeys: String, CodingKey {
            case kind = "type"
            case _markIn = "markIn"
            case _markOut = "markOut"
        }

        enum Kind: String, Decodable {
            case openingCredits = "OPENING_CREDITS"
            case closingCredits = "CLOSING_CREDITS"
        }

        private let _markIn: Int64
        private let _markOut: Int64

        let kind: Kind

        var timeRange: CMTimeRange {
            CMTimeRange(
                start: .init(value: _markIn, timescale: 1000),
                end: .init(value: _markOut, timescale: 1000)
            )
        }
    }
}
