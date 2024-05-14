//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaPlayer

/// Metadata associated with playback.
public struct PlayerMetadata: Equatable {
    static let empty = Self()

    /// An identifier for the content.
    public let identifier: String?

    /// The content title
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

    /// The image associated with the content.
    public var image: UIImage? {
        imageSource.image
    }

    private let imageSource: ImageSource

    /// Episode information associated with the content.
    public let episodeInformation: EpisodeInformation?

    /// Chapters associated with the content.
    public let chapters: [Chapter]

    /// Time ranges associated with the content.
    public let timeRanges: [TimeRange]

    let blockedTimeRanges: [CMTimeRange]

    var episodeDescription: String? {
        switch episodeInformation {
        case let .long(season: season, episode: episode):
            return String(localized: "S\(season), E\(episode)", bundle: .module, comment: "Short season / episode information")
        case let .short(episode: episode):
            return String(localized: "E\(episode)", bundle: .module, comment: "Short episode information")
        case nil:
            return nil
        }
    }

    var externalMetadata: [AVMetadataItem] {
        [
            .init(identifier: .commonIdentifierAssetIdentifier, value: identifier),
            .init(identifier: .commonIdentifierTitle, value: title),
            .init(identifier: .iTunesMetadataTrackSubTitle, value: subtitle),
            .init(identifier: .commonIdentifierDescription, value: description),
            .init(identifier: .commonIdentifierArtwork, value: artworkData),
            .init(identifier: .quickTimeUserDataCreationDate, value: episodeDescription)
        ].compactMap { $0 }
    }

    var nowPlayingInfo: NowPlaying.Info {
        var nowPlayingInfo = NowPlaying.Info()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = subtitle
        if let image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    var timedNavigationMarkers: [AVTimedMetadataGroup] {
        chapters.map(\.timedNavigationMarker)
    }

    private var artworkData: Data? {
#if os(tvOS)
        image?.pngData()
#else
        nil
#endif
    }

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content.
    ///   - title: The content title.
    ///   - subtitle: A subtitle for the content.
    ///   - description: A description of the content.
    ///   - imageSource: The source of the image associated with the content.
    ///   - episodeInformation: Episode information associated with the content.
    ///   - chapters: Chapter associated with the content.
    ///   - timeRanges: Time ranges associated with the content.
    ///
    /// The image should usually be reasonable in size (less than 1000px wide / tall is in general sufficient).
    public init(
        identifier: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        imageSource: ImageSource = .none,
        episodeInformation: EpisodeInformation? = nil,
        chapters: [Chapter] = [],
        timeRanges: [TimeRange] = []
    ) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageSource = imageSource
        self.episodeInformation = episodeInformation
        self.chapters = chapters
        self.timeRanges = timeRanges
        self.blockedTimeRanges = Self.flattenedBlockedTimeRanges(from: timeRanges)
    }

    private static func flattenedBlockedTimeRanges(from timeRanges: [TimeRange]) -> [CMTimeRange] {
        CMTimeRange.flatten(timeRanges.filter { $0.kind == .blocked }.map { .init(start: $0.start, end: $0.end) })
    }
}

extension PlayerMetadata {
    func playerMetadataPublisher() -> AnyPublisher<PlayerMetadata, Never> {
        Publishers.CombineLatest(
            imageSource.imageSourcePublisher(),
            chaptersPublisher()
        )
        .map { self.with(imageSource: $0, chapters: $1) }
        .eraseToAnyPublisher()
    }

    private func chaptersPublisher() -> AnyPublisher<[Chapter], Never> {
        Publishers.AccumulateLatestMany(chapters.map { $0.chapterPublisher() })
    }

    private func with(imageSource: ImageSource, chapters: [Chapter]) -> Self {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges
        )
    }
}
