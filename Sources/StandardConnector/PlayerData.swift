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

    /// An identifier for the content.
    public let identifier: String?

    /// The content title.
    ///
    /// For example the name of the show which the content is associated with, if any, otherwise the name
    /// of the episode itself.
    public let title: String?

    /// A subtitle for the content.
    ///
    /// For example the name of the episode when a show name has been provided as title.
    public let subtitle: String?

    /// A description of the content.
    public let description: String?

    /// The poster URL associated with the content.
    public let posterUrl: URL?

    /// Season number.
    public let seasonNumber: Int?

    /// Episode number.
    public let episodeNumber: Int?

    /// The content viewport.
    public let viewport: Viewport?

    /// Chapters associated with the content.
    public var chapters: [Chapter] {
        _chapters ?? []
    }

    /// Time ranges associated with the content.
    public var timeRanges: [TimeRange] {
        _timeRanges ?? []
    }

    /// The source.
    public let source: Source?

    /// The DRM.
    public let drm: DRM?

    /// Custom data associated with the content.
    public let customData: CustomData?

    // swiftlint:disable:next discouraged_optional_collection
    private let _chapters: [Chapter]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _timeRanges: [TimeRange]?
}

extension PlayerData {
    var episodeInformation: EpisodeInformation? {
        guard let episodeNumber else { return nil }
        return .init(episode: episodeNumber, season: seasonNumber)
    }

    var playerChapters: [PillarboxPlayer::Chapter] {
        guard let _chapters else { return [] }
        return _chapters.map { chapter in
            PillarboxPlayer::Chapter(
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

    var playerTimeRanges: [PillarboxPlayer::TimeRange] {
        _timeRanges?.map(\.playerTimeRange) ?? []
    }

    var playerMetadata: PlayerMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: Self.imageSource(from: posterUrl),
            viewport: playerViewport,
            episodeInformation: episodeInformation,
            chapters: playerChapters,
            timeRanges: playerTimeRanges
        )
    }

    private static func imageSource(from url: URL?) -> ImageSource {
        guard let url else { return .none }
        return .url(standardResolution: url)
    }
}

public extension PlayerData {
    /// A chapter representation.
    struct Chapter: Decodable {
        /// An identifier for the chapter.
        public let identifier: String?

        /// The chapter title.
        public let title: String

        /// The poster URL associated with the content.
        public let posterUrl: URL?

        /// The start time in milliseconds.
        public let startTime: Int

        /// The end time in milliseconds.
        public let endTime: Int
    }

    /// Represents a time range.
    struct TimeRange: Decodable {
        /// The start time in milliseconds.
        public let startTime: Int

        /// The end time in milliseconds.
        public let endTime: Int

        /// The type.
        ///
        /// `BLOCKED`, `OPENING_CREDITS`, `CLOSING_CREDITS` are natively supported.
        public let type: String

        // swiftlint:disable:next prefer_self_in_static_references
        private var kind: PillarboxPlayer::TimeRange.Kind {
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

        // swiftlint:disable:next prefer_self_in_static_references
        var playerTimeRange: PillarboxPlayer::TimeRange {
            .init(
                kind: kind,
                start: .init(value: CMTimeValue(startTime), timescale: 1000),
                end: .init(value: CMTimeValue(endTime), timescale: 1000)
            )
        }
    }
}

extension PlayerData {
    /// A video viewport.
    public enum Viewport: String, Decodable {
        /// Standard viewport.
        case standard = "STANDARD"

        /// Monoscopic viewport.
        case monoscopic = "MONOSCOPIC"
    }

    var playerViewport: PillarboxPlayer::Viewport {
        switch viewport {
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

    /// Represents the media source for a playable asset.
    struct Source: Decodable {
        /// The media URL.
        public let url: URL
    }
}
