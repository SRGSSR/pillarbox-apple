//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A description of an episode.
public struct Episode: Decodable {
    enum CodingKeys: String, CodingKey {
        case episode = "number"
        case season = "seasonNumber"
    }

    /// The season number.
    public let season: Int?

    /// The episode number.
    public let episode: Int?
}
