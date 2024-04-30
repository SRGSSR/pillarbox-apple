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
            case blockingReason = "blockReason"
            case _markIn = "markIn"
            case _markOut = "markOut"
        }

        /// Returns whether the content is blocked for some reason.
        public let blockingReason: BlockingReason?

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
