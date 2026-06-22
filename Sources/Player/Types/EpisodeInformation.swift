//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Information about an episode.
public struct EpisodeInformation: Codable, Equatable {
    /// Episode number.
    public let episode: Int

    /// Season number.
    public let season: Int?

    /// Creates episode information.
    public init(episode: Int, season: Int? = nil) {
        self.episode = episode
        self.season = season
    }
}
