//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Information about an episode.
public enum EpisodeInformation: Equatable {
    /// Season and episode number.
    case long(season: Int, episode: Int)

    /// Episode number only.
    case short(episode: Int)
}
