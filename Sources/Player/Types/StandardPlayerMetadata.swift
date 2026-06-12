//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

// FIXME: Remove when minimum target is 17 and use `Never` instead.
struct EmptyCustomData: Equatable, Codable {}

typealias MinimalPlayerMetadata = StandardPlayerMetadata<EmptyCustomData>

struct StandardPlayerMetadata<CustomData>: Codable where CustomData: Codable {
    enum CodingKeys: String, CodingKey {
        case _chapters = "chapters"
        case _timeRanges = "timeRanges"
        case customData
        case description
        case drm
        case episodeNumber
        case identifier
        case posterUrl
        case seasonNumber
        case source
        case subtitle
        case title
        case viewport
    }

    let identifier: String?
    let title: String?
    let subtitle: String?
    let description: String?
    let posterUrl: URL?
    let seasonNumber: Int?
    let episodeNumber: Int?
    let viewport: Viewport?
    let drm: DRM?
    let source: Source?
    let customData: CustomData?

    // swiftlint:disable:next discouraged_optional_collection
    private let _chapters: [Chapter]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _timeRanges: [TimeRange]?

    var chapters: [Chapter] {
        _chapters ?? []
    }

    var timeRanges: [TimeRange] {
        _timeRanges ?? []
    }
}

extension StandardPlayerMetadata {
    struct Chapter: Equatable, Codable {
        let identifier: String?
        let title: String
        let posterUrl: URL?
        let startTime: Int
        let endTime: Int
    }

    struct DRM: Equatable, Codable {
        let certificateUrl: URL?
    }

    struct Source: Equatable, Codable {
        let url: URL
    }

    struct TimeRange: Equatable, Codable {
        let startTime: Int
        let endTime: Int
        let type: String
    }

    enum Viewport: String, Equatable, Codable {
        case standard = "STANDARD"
        case monoscopic = "MONOSCOPIC"
    }
}

extension StandardPlayerMetadata: Equatable where CustomData: Equatable {}
