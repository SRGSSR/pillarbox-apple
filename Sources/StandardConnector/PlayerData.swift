//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation
import PillarboxPlayer

/// Metadata associated with content loaded.
public struct PlayerData<CustomData: Decodable>: Decodable {
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
    private let _chapters: [_Chapter]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _timeRanges: [_TimeRange]?
    let customData: CustomData?
}

extension PlayerData: AssetMetadata {
    // swiftlint:disable:next missing_docs
    public var playerMetadata: PlayerMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource(from: posterUrl),
            viewport: .standard,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges
        )
    }

    var episodeInformation: EpisodeInformation? {
        guard let episodeNumber else { return nil }
        if let seasonNumber {
            return .long(season: seasonNumber, episode: episodeNumber)
        }
        else {
            return .short(episode: episodeNumber)
        }
    }

    var chapters: [Chapter] {
        guard let _chapters else { return [] }
        return _chapters.map { chapter in
            Chapter(
                identifier: chapter.identifier,
                title: chapter.title,
                imageSource: imageSource(from: chapter.posterUrl),
                timeRange: .init(
                    start: .init(value: CMTimeValue(chapter.startTime), timescale: 1000),
                    end: .init(value: CMTimeValue(chapter.endTime), timescale: 1000)
                )
            )
        }
    }

    var timeRanges: [TimeRange] {
        _timeRanges?.map(\.timeRange) ?? []
    }

    private func imageSource(from url: URL?) -> ImageSource {
        guard let posterUrl else { return .none }
        return .url(standardResolution: posterUrl)
    }
}

extension PlayerData {
    private struct _Chapter: Decodable {
        let identifier: String?
        let title: String
        let posterUrl: URL?
        let startTime: Int
        let endTime: Int
    }

    private struct _TimeRange: Decodable {
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
