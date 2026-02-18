//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation
import PillarboxPlayer

// FIXME: Remove when minimum target is 17 and use `Never` instead.
/// An object representing the absence of custom data.
public struct EmptyCustomData: Decodable {}

/// Metadata associated with content loaded in a player.
///
/// Represents the standard metadata returned by a backend endpoint and used to configure a playable `Asset`.
public struct PlayerData<CustomData>: Decodable where CustomData: Decodable {
    enum CodingKeys: String, CodingKey {
        case _chapters = "chapters"
        case _timeRanges = "timeRanges"
        case _viewport = "viewport"
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
    }

    private let identifier: String?
    private let title: String?
    private let subtitle: String?
    private let description: String?
    private let posterUrl: URL?
    private let seasonNumber: Int?
    private let episodeNumber: Int?
    private let _viewport: _Viewport?

    // swiftlint:disable:next discouraged_optional_collection
    private let _chapters: [_Chapter]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _timeRanges: [_TimeRange]?

    /// The source.
    public let source: Source?

    /// The DRM.
    public let drm: DRM?

    /// Custom data.
    public let customData: CustomData?
}

extension PlayerData: AssetMetadata {
    // swiftlint:disable:next missing_docs
    public var playerMetadata: PlayerMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: Self.imageSource(from: posterUrl),
            viewport: viewport,
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
                imageSource: Self.imageSource(from: chapter.posterUrl),
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

    private static func imageSource(from url: URL?) -> ImageSource {
        guard let url else { return .none }
        return .url(standardResolution: url)
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

extension PlayerData {
    private enum _Viewport: String, Decodable {
        case standard = "STANDARD"
        case monoscopic = "MONOSCOPIC"
    }

    var viewport: Viewport {
        switch _viewport {
        case .standard, .none:
            return .standard
        case .monoscopic:
            return .monoscopic
        }
    }
}

public extension PlayerData {
    /// A DRM protection description.
    struct DRM: Decodable {
        /// The certificate URL.
        public let certificateUrl: URL?
    }
}
