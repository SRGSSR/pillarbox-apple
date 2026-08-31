//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

// swiftlint:disable missing_docs

public struct EmptyCustomData: Codable {
    private var _reserved = ""
}

public typealias AssetPlayerMetadata = AssetMetadata<EmptyCustomData>

public struct AssetMetadata<CustomData> {
    public let playerMetadata: PlayerMetadata
    public let customData: CustomData

    public init(playerMetadata: PlayerMetadata, customData: CustomData) {
        self.playerMetadata = playerMetadata
        self.customData = customData
    }

    func withoutCustomData() -> AssetMetadata<Void> {
        .init(playerMetadata: playerMetadata, customData: ())
    }

    func assetMetadataPublisher() -> AnyPublisher<AssetMetadata<CustomData>, Never> {
        Publishers.CombineLatest(
            playerMetadata.playerMetadataPublisher(),
            Just(customData)
        )
        .map { .init(playerMetadata: $0, customData: $1) }
        .eraseToAnyPublisher()
    }
}

extension AssetMetadata: Codable where CustomData: Codable {}

public extension AssetPlayerMetadata {
    init(playerMetadata: PlayerMetadata) {
        self.playerMetadata = playerMetadata
        self.customData = .init()
    }
}

public extension AssetPlayerMetadata {
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
    ///
    /// The image should usually be reasonable in size (less than 1000px wide / tall is in general sufficient).
    init(
        identifier: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        imageSource: ImageSource = .none,
        viewport: Viewport = .standard,
        episodeInformation: EpisodeInformation? = nil,
        chapters: [Chapter] = [],
        timeRanges: [TimeRange] = []
    ) {
        self.init(
            playerMetadata: .init(
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
        )
    }

    /// An identifier for the content.
    var identifier: String? {
        playerMetadata.identifier
    }

    /// The content title
    ///
    /// For example the name of the show which the content is associated with, if any, otherwise the name
    /// of the episode itself.
    var title: String? {
        playerMetadata.title
    }

    /// A subtitle for the content.
    ///
    /// For example the name of the episode when a show name has been provided as title.
    var subtitle: String? {
        playerMetadata.subtitle
    }

    /// A description of the content.
    var description: String? {
        playerMetadata.description
    }

    /// The source of the image associated with the content.
    var imageSource: ImageSource {
        playerMetadata.imageSource
    }

    /// The content viewport.
    var viewport: Viewport {
        playerMetadata.viewport
    }

    /// Episode information associated with the content.
    var episodeInformation: EpisodeInformation? {
        playerMetadata.episodeInformation
    }

    /// Chapters associated with the content.
    var chapters: [Chapter] {
        playerMetadata.chapters
    }

    /// Time ranges associated with the content.
    var timeRanges: [TimeRange] {
        playerMetadata.timeRanges
    }
}

// swiftlint:enable missing_docs
