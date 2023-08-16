//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A stream description.
public struct Stream {
    /// The stream URL.
    public let url: URL

    /// The stream duration.
    public let duration: CMTime

    /// Returns a stream identifying some item in a playlist, having a specific index.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    /// - Parameter index: The index.
    /// - Returns: The stream.
    public static func item(numbered index: Int) -> Self {
        .init(
            url: URL(string: "https://www.server.com/item\(index).m3u8")!,
            duration: .indefinite
        )
    }
}

public extension Stream {
    /// An on-demand stream.
    static let onDemand: Self = .init(
        url: URL(string: "http://localhost:8123/single/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// A short on-demand stream.
    static let shortOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/single/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )

    /// A medium-sized on-demand stream.
    static let mediumOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/single/on_demand_medium/master.m3u8")!,
        duration: CMTime(value: 5, timescale: 1)
    )

    /// A square on-demand stream.
    static let squareOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/single/on_demand_square/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// A corrupt on-demand stream.
    static let corruptOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/single/on_demand_corrupt/master.m3u8")!,
        duration: CMTime(value: 2, timescale: 1)
    )

    /// A live stream.
    static let live: Self = .init(
        url: URL(string: "http://localhost:8123/single/live/master.m3u8")!,
        duration: .zero
    )

    /// A DVR stream.
    static let dvr: Self = .init(
        url: URL(string: "http://localhost:8123/single/dvr/master.m3u8")!,
        duration: CMTime(value: 17 /* 20 - 3 * 1 (chunk) */, timescale: 1)
    )
}

public extension Stream {
    /// An on-demand stream with several subtitles and audio tracks.
    static let onDemandWithTracks: Self = .init(
        url: URL(string: "http://localhost:8123/multi/on_demand_with_tracks/master.m3u8")!,
        duration: CMTime(value: 4, timescale: 1)
    )

    /// An on-demand stream without subtitles and audio tracks.
    static let onDemandWithoutTracks: Self = .init(
        url: URL(string: "http://localhost:8123/multi/on_demand_without_tracks/master.m3u8")!,
        duration: CMTime(value: 4, timescale: 1)
    )

    /// An on-demand stream with forced subtitles.
    static let onDemandWithForcedSubtitles: Self = .init(
        // TODO: Should update to a local stream when forced subtitles are supported by Shaka Packager.
        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
        duration: CMTime(value: 1800, timescale: 1)
    )
}

public extension Stream {
    /// An unavailable stream.
    static let unavailable: Self = .init(
        url: URL(string: "http://localhost:8123/unavailable/master.m3u8")!,
        duration: .indefinite
    )

    /// An MP3 stream.
    static let mp3: Self = .init(
        url: Bundle.module.url(forResource: "silence", withExtension: "mp3")!,
        duration: CMTime(value: 5, timescale: 1)
    )
}

public extension Stream {
    /// A stream with a custom scheme.
    ///
    /// Not intended to be playable.
    static let custom: Self = .init(
        url: URL(string: "custom://arbitrary.server/some.m3u8")!,
        duration: .indefinite
    )

    /// A stream identifying some item in a playlist.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    static let item: Self = .init(
        url: URL(string: "https://www.server.com/item.m3u8")!,
        duration: .indefinite
    )

    /// A stream identifying an item inserted into a playlist.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    static let insertedItem: Self = .init(
        url: URL(string: "https://www.server.com/inserted.m3u8")!,
        duration: .indefinite
    )

    /// A stream identifying a foreign item not belonging to a playlist.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    static let foreignItem: Self = .init(
        url: URL(string: "https://www.server.com/foreign.m3u8")!,
        duration: .indefinite
    )
}
