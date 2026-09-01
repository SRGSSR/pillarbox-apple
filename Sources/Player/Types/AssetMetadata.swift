//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaPlayer

/// Metadata associated with playback.
public struct AssetMetadata<CustomData> {
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

    /// The source of the image associated with the content.
    public let imageSource: ImageSource

    /// The content viewport.
    public let viewport: Viewport

    /// Episode information associated with the content.
    public let episodeInformation: EpisodeInformation?

    /// Chapters associated with the content.
    public let chapters: [Chapter]

    /// Time ranges associated with the content.
    public let timeRanges: [TimeRange]

    /// Custom data associated with the content.
    public let customData: CustomData

    var blockedTimeRanges: [CMTimeRange] {
        CMTimeRange.flatten(timeRanges.filter { $0.kind == .blocked }.map { .init(start: $0.start, end: $0.end) })
    }

    var episodeDescription: String? {
        guard let episodeInformation else { return nil }
        if let season = episodeInformation.season {
            return String(localized: "S\(season), E\(episodeInformation.episode)", bundle: .module, comment: "Short season / episode information")
        }
        else {
            return String(localized: "E\(episodeInformation.episode)", bundle: .module, comment: "Short episode information")
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
        ].compactMap(\.self)
    }

    var nowPlayingInfo: NowPlaying.Info {
        var nowPlayingInfo = NowPlaying.Info()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = subtitle
        if let artworkData = imageSource.fetchData(), let artworkImage = UIImage(data: artworkData) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
        }
        return nowPlayingInfo
    }

    var timedNavigationMarkers: [AVTimedMetadataGroup] {
        chapters.map(\.timedNavigationMarker)
    }

    var playerMetadata: PlayerMetadata {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource,
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges,
            customData: .init()
        )
    }

    private var artworkData: Data? {
#if os(tvOS)
        imageSource.fetchData()
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
    ///   - viewport: The content viewport.
    ///   - episodeInformation: Episode information associated with the content.
    ///   - chapters: Chapter associated with the content.
    ///   - timeRanges: Time ranges associated with the content.
    ///   - customData: Custom data associated with the content.
    ///
    /// The image should usually be reasonable in size (less than 1000px wide / tall is in general sufficient).
    public init(
        identifier: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        imageSource: ImageSource = .none,
        viewport: Viewport = .standard,
        episodeInformation: EpisodeInformation? = nil,
        chapters: [Chapter] = [],
        timeRanges: [TimeRange] = [],
        customData: CustomData
    ) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageSource = imageSource
        self.viewport = viewport
        self.episodeInformation = episodeInformation
        self.chapters = chapters
        self.timeRanges = timeRanges
        self.customData = customData
    }

    func assetMetadataPublisher() -> AnyPublisher<AssetMetadata<CustomData>, Never> {
        Publishers.CombineLatest(
            playerMetadata.playerMetadataPublisher(),
            Just(customData)
        )
        .map { $0.withCustomData($1) }
        .eraseToAnyPublisher()
    }
}

extension AssetMetadata: Equatable where CustomData: Equatable {}
extension AssetMetadata: Codable where CustomData: Codable {}

extension AssetMetadata {
    func lazyPlayerMetadataPublisher() -> AnyPublisher<AssetMetadata, Never> {
        Publishers.CombineLatest(
            imageSource.lazyImageSourcePublisher(),
            lazyChaptersPublisher()
        )
        .map { withImageSource($0).withChapters($1) }
        .eraseToAnyPublisher()
    }

    private func lazyChaptersPublisher() -> AnyPublisher<[Chapter], Never> {
        Publishers.AccumulateLatestMany(chapters.map { $0.lazyChapterPublisher() })
    }
}

extension AssetMetadata {
    func playerMetadataPublisher() -> AnyPublisher<AssetMetadata, Never> {
        Publishers.CombineLatest(
            imageSource.imageSourcePublisher(),
            chaptersPublisher()
        )
        .map { withImageSource($0).withChapters($1) }
        .eraseToAnyPublisher()
    }

    private func chaptersPublisher() -> AnyPublisher<[Chapter], Never> {
        Publishers.AccumulateLatestMany(chapters.map { $0.chapterPublisher() })
    }
}

extension AssetMetadata {
    func withImageSource(_ imageSource: ImageSource) -> Self {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource,
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges,
            customData: customData
        )
    }

    func withChapters(_ chapters: [Chapter]) -> Self {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource,
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges,
            customData: customData
        )
    }

    func withCustomData<OtherCustomData>(_ customData: OtherCustomData) -> AssetMetadata<OtherCustomData> {
        .init(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: imageSource,
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges,
            customData: customData
        )
    }
}
