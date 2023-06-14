//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A stream description.
public struct Stream {
    /// An on-demand stream.
    public static let onDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// A short on-demand stream.
    public static let shortOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )

    /// A medium-sized on-demand stream.
    public static let mediumOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_medium/master.m3u8")!,
        duration: CMTime(value: 5, timescale: 1)
    )

    /// A cropped on-demand stream.
    public static let croppedOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_cropped/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// A corrupt on-demand stream.
    public static let corruptOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_corrupt/master.m3u8")!,
        duration: CMTime(value: 2, timescale: 1)
    )

    /// A live stream.
    public static let live: Self = .init(
        url: URL(string: "http://localhost:8123/live/master.m3u8")!,
        duration: .zero
    )

    /// A DVR stream.
    public static let dvr: Self = .init(
        url: URL(string: "http://localhost:8123/dvr/master.m3u8")!,
        duration: CMTime(value: 17 /* 20 - 3 * 1 (chunk) */, timescale: 1)
    )

    /// An MP3 stream.
    public static let mp3: Self = .init(
        url: Bundle.module.url(forResource: "silence", withExtension: "mp3")!,
        duration: CMTime(value: 5, timescale: 1)
    )

    /// An unavailable stream.
    public static let unavailable: Self = .init(
        url: URL(string: "http://localhost:8123/unavailable/master.m3u8")!,
        duration: .indefinite
    )

    /// A stream with a custom scheme.
    ///
    /// Not intended to be playable.
    public static let custom: Self = .init(
        url: URL(string: "custom://arbitrary.server/some.m3u8")!,
        duration: .indefinite
    )

    /// A stream identifying some item in a playlist.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    public static let item: Self = .init(
        url: URL(string: "https://www.server.com/item.m3u8")!,
        duration: .indefinite
    )

    /// A stream identifying an item inserted into a playlist.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    public static let insertedItem: Self = .init(
        url: URL(string: "https://www.server.com/inserted.m3u8")!,
        duration: .indefinite
    )

    /// A stream identifying a foreign item not belonging to a playlist.
    ///
    /// Not intended to be playable, mostly useful for testing playlist mutations.
    public static let foreignItem: Self = .init(
        url: URL(string: "https://www.server.com/foreign.m3u8")!,
        duration: .indefinite
    )

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
