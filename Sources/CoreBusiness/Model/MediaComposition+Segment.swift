//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension MediaComposition {
    /// A chapter section.
    struct Segment: Decodable {
        enum CodingKeys: String, CodingKey {
            case _blockingReason = "blockReason"
            case _markIn = "markIn"
            case _markOut = "markOut"
            case _validFrom = "validFrom"
            case _validTo = "validTo"
        }

        /// Returns whether the content is blocked for some reason.
        public var blockingReason: BlockingReason? {
            _blockingReason?.blockingReason(startDate: _validFrom, endDate: _validTo)
        }

        /// The associated time range.
        public var timeRange: CMTimeRange {
            CMTimeRange(
                start: .init(value: _markIn, timescale: 1000),
                end: .init(value: _markOut, timescale: 1000)
            )
        }

        private let _markIn: Int64
        private let _markOut: Int64
        private let _blockingReason: _BlockingReason?
        private let _validFrom: Date?
        private let _validTo: Date?
    }
}
