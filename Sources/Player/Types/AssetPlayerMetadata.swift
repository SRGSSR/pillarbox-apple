//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

public typealias AssetPlayerMetadata = AssetMetadata<EmptyCustomData>

extension AssetPlayerMetadata {
    init(playerMetadata: PlayerMetadata) {
        self.playerMetadata = playerMetadata
        self.customData = .init()
    }
}

public extension AssetPlayerMetadata {
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
