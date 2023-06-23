//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A content providing a playable resource.
public struct Segment: Decodable {
    /// The segment URN.
    public let urn: String

    /// The segment range.
    public var mark: ClosedRange<Int> { markIn...markOut }

    // The segment starting position.
    private let markIn: Int

    // The segment ending position.
    private let markOut: Int
}
