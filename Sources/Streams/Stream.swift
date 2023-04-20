//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Sample streams.
public struct Stream {
    /// On-demand.
    public static let onDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// Short on-demand.
    public static let shortOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )

    /// Cropped on-demand.
    public static let croppedOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_cropped/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// Corrupt on-demand.
    public static let corruptOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_corrupt/master.m3u8")!,
        duration: CMTime(value: 2, timescale: 1)
    )

    /// Live.
    public static let live: Self = .init(
        url: URL(string: "http://localhost:8123/live/master.m3u8")!,
        duration: .zero
    )

    /// DVR.
    public static let dvr: Self = .init(
        url: URL(string: "http://localhost:8123/dvr/master.m3u8")!,
        duration: CMTime(value: 17 /* 20 - 3 * 1 (chunk) */, timescale: 1)
    )

    /// MP3.
    public static let mp3: Self = .init(
        url: Bundle.module.url(forResource: "silence", withExtension: "mp3")!,
        duration: CMTime(value: 5, timescale: 1)
    )

    /// Unavailable.
    public static let unavailable: Self = .init(
        url: URL(string: "http://localhost:8123/unavailable/master.m3u8")!,
        duration: .indefinite
    )

    /// Custom.
    public static let custom: Self = .init(
        url: URL(string: "custom://arbitrary.server/some.m3u8")!,
        duration: .indefinite
    )

    /// Item.
    public static let item: Self = .init(
        url: URL(string: "https://www.server.com/item.m3u8")!,
        duration: .indefinite
    )

    /// Inserted item.
    public static let insertedItem: Self = .init(
        url: URL(string: "https://www.server.com/inserted.m3u8")!,
        duration: .indefinite
    )

    /// Foreign item.
    public static let foreignItem: Self = .init(
        url: URL(string: "https://www.server.com/foreign.m3u8")!,
        duration: .indefinite
    )

    /// URL.
    public let url: URL

    /// Duration.
    public let duration: CMTime

    /// A stream whose master playlist contains an index. Not meant to be playable but useful for testing `AVPlayerItem`
    /// identity.
    /// - Parameter index: The index.
    /// - Returns: The stream.
    public static func item(numbered index: Int) -> Self {
        .init(
            url: URL(string: "https://www.server.com/item\(index).m3u8")!,
            duration: .indefinite
        )
    }
}
