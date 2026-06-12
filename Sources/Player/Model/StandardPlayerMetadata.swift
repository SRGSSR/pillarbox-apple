//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

// FIXME: Remove when minimum target is 17 and use `Never` instead.
struct EmptyCustomData: Equatable, Codable {}

typealias MinimalStandardPlayerMetadata = StandardPlayerMetadata<EmptyCustomData>

struct StandardPlayerMetadata<CustomData>: Codable where CustomData: Codable {
    enum CodingKeys: String, CodingKey {
        case _chapters = "chapters"
        case _episodeNumber = "episodeNumber"
        case _posterUrl = "posterUrl"
        case _seasonNumber = "seasonNumber"
        case _timeRanges = "timeRanges"
        case _viewport = "viewport"
        case customData
        case description
        case drm
        case identifier
        case source
        case subtitle
        case title
    }

    let identifier: String?
    let title: String?
    let subtitle: String?
    let description: String?

    private let _posterUrl: URL?
    private let _seasonNumber: Int?
    private let _episodeNumber: Int?
    private let _viewport: StandardViewport?

    let drm: StandardDRM?
    let source: StandardSource?

    let customData: CustomData?

    // swiftlint:disable:next discouraged_optional_collection
    private let _chapters: [StandardChapter]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _timeRanges: [StandardTimeRange]?
}

extension StandardPlayerMetadata {
    var chapters: [Chapter] {
        guard let _chapters else { return [] }
        return _chapters.map { chapter in
            Chapter(
                identifier: chapter.identifier,
                title: chapter.title,
                imageSource: Self.imageSource(from: chapter.posterUrl),
                timeRange: .init(
                    start: .init(value: CMTimeValue(chapter.startTime), timescale: 1000),
                    end: .init(value: CMTimeValue(chapter.endTime), timescale: 1000)
                )
            )
        }
    }

    var episodeInformation: EpisodeInformation? {
        guard let _episodeNumber else { return nil }
        if let _seasonNumber {
            return .long(season: _seasonNumber, episode: _episodeNumber)
        }
        else {
            return .short(episode: _episodeNumber)
        }
    }

    var imageSource: ImageSource {
        Self.imageSource(from: _posterUrl)
    }

    var timeRanges: [TimeRange] {
        _timeRanges?.map(\.timeRange) ?? []
    }

    var viewport: Viewport {
        switch _viewport {
        case .standard, .none:
            return .standard
        case .monoscopic:
            return .monoscopic
        }
    }

    private static func imageSource(from url: URL?) -> ImageSource {
        guard let url else { return .none }
        return .url(standardResolution: url)
    }
}

extension StandardPlayerMetadata: Equatable where CustomData: Equatable {}
