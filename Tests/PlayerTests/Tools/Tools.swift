//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

typealias EmptyAsset = Asset<Never>

struct StructError: LocalizedError {
    var errorDescription: String? {
        "Struct error description"
    }
}

enum EnumError: Int, Error {
    case error1 = 1
    case error2
}

enum PlayerError {
    static var resourceNotFound: NSError {
        NSError(
            domain: URLError.errorDomain,
            code: URLError.fileDoesNotExist.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "The requested URL was not found on this server.",
                NSUnderlyingErrorKey: NSError(
                    domain: "CoreMediaErrorDomain",
                    code: -12938,
                    userInfo: [
                        "NSDescription": "HTTP 404: File Not Found"
                    ]
                )
            ]
        )
    }

    static var segmentNotFound: NSError {
        NSError(
            domain: "CoreMediaErrorDomain",
            code: -12938,
            userInfo: [
                NSLocalizedDescriptionKey: "HTTP 404: File Not Found"
            ]
        )
    }
}

struct Stream {
    static let onDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    static let shortOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )

    static let croppedOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_cropped/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )

    static let corruptOnDemand: Self = .init(
        url: URL(string: "http://localhost:8123/on_demand_corrupt/master.m3u8")!,
        duration: CMTime(value: 2, timescale: 1)
    )

    static let live: Self = .init(
        url: URL(string: "http://localhost:8123/live/master.m3u8")!,
        duration: .zero
    )

    static let dvr: Self = .init(
        url: URL(string: "http://localhost:8123/dvr/master.m3u8")!,
        duration: CMTime(value: 17 /* 20 - 3 * 1 (chunk) */, timescale: 1)
    )

    static let mp3: Self = .init(
        url: Bundle.test.url(forResource: "silence", withExtension: "mp3")!,
        duration: CMTime(value: 5, timescale: 1)
    )

    static let unavailable: Self = .init(
        url: URL(string: "http://localhost:8123/unavailable/master.m3u8")!,
        duration: .indefinite
    )

    static let custom: Self = .init(
        url: URL(string: "custom://arbitrary.server/some.m3u8")!,
        duration: .indefinite
    )

    static var item: Self = .init(
        url: URL(string: "https://www.server.com/item.m3u8")!,
        duration: .indefinite
    )

    static var insertedItem: Self = .init(
        url: URL(string: "https://www.server.com/inserted.m3u8")!,
        duration: .indefinite
    )

    static var foreignItem: Self = .init(
        url: URL(string: "https://www.server.com/foreign.m3u8")!,
        duration: .indefinite
    )

    let url: URL
    let duration: CMTime

    static func item(numbered index: Int) -> Self {
        .init(
            url: URL(string: "https://www.server.com/item\(index).m3u8")!,
            duration: .indefinite
        )
    }
}

extension UUID {
    init(_ char: Character) {
        self.init(
            uuidString: """
            \(String(repeating: char, count: 8))\
            -\(String(repeating: char, count: 4))\
            -\(String(repeating: char, count: 4))\
            -\(String(repeating: char, count: 4))\
            -\(String(repeating: char, count: 12))
            """
        )!
    }
}
