//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct PlayerData<CustomData: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case subtitle
        case description
        case posterUrl
        case seasonNumber
        case episodeNumber
        case source
        case _chapters = "chapters"
        case _timeRanges = "timeRanges"
        case customData
    }

    let identifier: String?
    let title: String?
    let subtitle: String?
    let description: String?
    let posterUrl: URL?
    let seasonNumber: Int?
    let episodeNumber: Int?
    let source: Source
    // swiftlint:disable:next discouraged_optional_collection
    let _chapters: [Chapter]?
    // swiftlint:disable:next discouraged_optional_collection
    let _timeRanges: [TimeRange]?
    let customData: CustomData?

    var chapters: [Chapter] {
        _chapters ?? []
    }

    var timeRanges: [TimeRange] {
        _timeRanges ?? []
    }
}
