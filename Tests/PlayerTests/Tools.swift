//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

enum EnumError: Error {
    case any
    case error1
    case error2
}

struct Stream {
    static let onDemand = Stream(
        url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    static let shortOnDemand = Stream(
        url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )

    static let corruptOnDemand = Stream(
        url: URL(string: "http://localhost:8123/on_demand_corrupt/master.m3u8")!,
        duration: CMTime(value: 2, timescale: 1)
    )

    static let live = Stream(
        url: URL(string: "http://localhost:8123/live/master.m3u8")!,
        duration: .zero
    )

    static let dvr = Stream(
        url: URL(string: "http://localhost:8123/dvr/master.m3u8")!,
        duration: CMTime(value: 20, timescale: 1)
    )

    static let unavailable = Stream(
        url: URL(string: "http://localhost:8123/unavailable/master.m3u8")!,
        duration: .indefinite
    )

    static let custom = Stream(
        url: URL(string: "custom://arbitrary.server/some.m3u8")!,
        duration: .indefinite
    )

    static var item = Stream(
        url: URL(string: "https://www.server.com/item.m3u8")!,
        duration: .indefinite
    )

    static var insertedItem = Stream(
        url: URL(string: "https://www.server.com/inserted.m3u8")!,
        duration: .indefinite
    )

    static var foreignItem = Stream(
        url: URL(string: "https://www.server.com/foreign.m3u8")!,
        duration: .indefinite
    )

    let url: URL
    let duration: CMTime

    static func item(numbered index: Int) -> Stream {
        Stream(
            url: URL(string: "https://www.server.com/item\(index).m3u8")!,
            duration: .indefinite
        )
    }
}
