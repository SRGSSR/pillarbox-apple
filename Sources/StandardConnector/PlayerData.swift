//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation
import PillarboxPlayer

/// Metadata associated with content loaded in a player.
///
/// Represents the standard metadata returned by a backend endpoint and used to configure a playable `Asset`.
public struct PlayerData<CustomData>: Decodable where CustomData: Decodable {
    enum CodingKeys: String, CodingKey {
        case _chapters = "chapters"
        case _drm = "drm"
        case _episodeNumber = "episodeNumber"
        case _posterUrl = "posterUrl"
        case _seasonNumber = "seasonNumber"
        case _source = "source"
        case _timeRanges = "timeRanges"
        case _viewport = "viewport"
        case customData
        case description
        case identifier
        case subtitle
        case title
    }

    let customData: CustomData?
    let description: String?
    let identifier: String?
    let subtitle: String?
    let title: String?

    // swiftlint:disable:next discouraged_optional_collection
    private let _chapters: [_Chapter]?
    private let _drm: _DRM?
    private let _episodeNumber: Int?
    private let _posterUrl: URL?
    private let _seasonNumber: Int?
    private let _source: _Source?
    // swiftlint:disable:next discouraged_optional_collection
    private let _timeRanges: [_TimeRange]?
    private let _viewport: _Viewport?
}

extension PlayerData {
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

    func playerMetadata() -> PlayerMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource,
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges
        )
    }
}

private extension PlayerData {
    struct _Chapter: Decodable {
        let identifier: String?
        let title: String
        let posterUrl: URL?
        let startTime: Int
        let endTime: Int
    }

    struct _DRM: Decodable {
        let certificateUrl: URL?
    }

    struct _Source: Decodable {
        let url: URL
    }

    enum _Viewport: String, Decodable {
        case standard = "STANDARD"
        case monoscopic = "MONOSCOPIC"
    }

    struct _TimeRange: Decodable {
        let startTime: Int
        let endTime: Int
        let type: String

        private var kind: TimeRange.Kind {
            switch type {
            case "BLOCKED":
                return .blocked
            case "OPENING_CREDITS":
                return .credits(.opening)
            case "CLOSING_CREDITS":
                return .credits(.closing)
            default:
                return .custom(type)
            }
        }

        var timeRange: TimeRange {
            .init(
                kind: kind,
                start: .init(value: CMTimeValue(startTime), timescale: 1000),
                end: .init(value: CMTimeValue(endTime), timescale: 1000)
            )
        }
    }
}
