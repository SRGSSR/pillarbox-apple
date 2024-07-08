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
}

public extension Stream {
    /// An on-demand stream.
    static let onDemand: Self = .init(
        url: URL(string: "http://localhost:8123/simple/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// A short on-demand stream.
    static let shortOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/simple/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )

    /// A medium-sized on-demand stream.
    static let mediumOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/simple/on_demand_medium/master.m3u8")!,
        duration: CMTime(value: 5, timescale: 1)
    )

    /// A square on-demand stream.
    static let squareOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/simple/on_demand_square/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    /// A live stream.
    static let live: Self = .init(
        url: URL(string: "http://localhost:8123/simple/live/master.m3u8")!,
        duration: .zero
    )

    /// A DVR stream.
    static let dvr: Self = .init(
        url: URL(string: "http://localhost:8123/simple/dvr/master.m3u8")!,
        duration: CMTime(value: 17 /* 20 - 3 * 1 (chunk) */, timescale: 1)
    )
}

public extension Stream {
    /// An on-demand stream with several audible and legible options.
    static let onDemandWithOptions: Self = .init(
        url: URL(string: "http://localhost:8123/packaged/on_demand_with_options/master.m3u8")!,
        duration: CMTime(value: 4, timescale: 1)
    )

    /// An on-demand stream without audible or legible options.
    static let onDemandWithoutOptions: Self = .init(
        url: URL(string: "http://localhost:8123/packaged/on_demand_without_options/master.m3u8")!,
        duration: CMTime(value: 4, timescale: 1)
    )

    /// An on-demand stream with a single audible option.
    static let onDemandWithSingleAudibleOption: Self = .init(
        url: URL(string: "http://localhost:8123/packaged/on_demand_with_single_audible_option/master.m3u8")!,
        duration: CMTime(value: 4, timescale: 1)
    )

    /// An on-demand stream with forced and unforced legible options.
    static let onDemandWithForcedAndUnforcedLegibleOptions: Self = .init(
        // TODO: Should update to a local stream when forced subtitles are supported by Shaka Packager.
        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
        duration: CMTime(value: 1800, timescale: 1)
    )

    /// An on-demand with many audible and legible options.
    static let onDemandWithManyLegibleAndAudibleOptions: Self = .init(
        url: URL(string: """
        https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8\
        ?cc=CH&svcId=tvs.vds.4021&a=1522121579&isExternal=true&brandId=tvs.sbd.4000&id=518077009&l=en-GB&aec=UHD
        """)!,
        duration: CMTime(value: 151, timescale: 1)
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

    /// An unavailable MP3 stream.
    static let unavailableMp3: Self = .init(
        url: URL(string: "http://localhost:8123/unavailable.mp3")!,
        duration: .indefinite
    )

    /// A MP3 live stream.
    static let liveMp3: Self = .init(
        url: URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!,
        duration: .indefinite
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

    /// An unauthorized stream.
    static let unauthorized: Self = .init(
        url: URL(string: "https://httpbin.org/status/403")!,
        duration: .indefinite
    )
}
