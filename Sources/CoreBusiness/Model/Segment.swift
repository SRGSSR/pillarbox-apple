//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A chapter section.
public struct Segment: Decodable {
    enum CodingKeys: String, CodingKey {
        case blockingReason = "blockReason"
        case markIn
        case markOut
    }

    /// Returns whether the content is blocked for some reason.
    public let blockingReason: BlockingReason?

    public let markIn: Int
    public let markOut: Int
}
